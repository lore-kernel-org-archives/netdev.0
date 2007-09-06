From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] devinet: show all addresses assigned to interface
Date: Thu, 6 Sep 2007 18:11:00 +0200
Message-ID: <20070906161100.GW18480@postel.suug.ch>
References: <20070906161000.74923fff@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:43357 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756957AbXIFQKk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Sep 2007 12:10:40 -0400
Content-Disposition: inline
In-Reply-To: <20070906161000.74923fff@oldman>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Stephen Hemminger <shemminger@linux-foundation.org> 2007-09-06 16:10
> Bug: http://bugzilla.kernel.org/show_bug.cgi?id=8876
> 
> Not all ips are shown by "ip addr show" command when IPs number assigned to an
> interface is more than 60-80 (in fact it depends on broadcast/label etc
> presence on each address).

The more attributes are assigned to an address, the sooner the netlink
message will be full.

> Steps to reproduce:
> It's terribly simple to reproduce:
> 
> # for i in $(seq 1 100); do ip ad add 10.0.$i.1/24 dev eth10 ; done
> # ip addr show
> 
> this will _not_ show all IPs.
> Looks like the problem is in netlink/ipv4 message processing.
> 
> This is fix from bug submitter, it looks correct.

The fix is correct.
