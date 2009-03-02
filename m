From: David Miller <davem@davemloft.net>
Subject: Re: Vlan interface nuisance
Date: Sun, 01 Mar 2009 20:57:02 -0800 (PST)
Message-ID: <20090301.205702.81302378.davem@davemloft.net>
References: <20090301204731.40ce346a@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36363
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754259AbZCBE5U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2009 23:57:20 -0500
In-Reply-To: <20090301204731.40ce346a@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Sun, 1 Mar 2009 20:47:31 -0800

> Why is interface created through netlink named 'vlan0' and
> interface created through old vconfig called 'ethX.YY'.
> Seems like the interface should be consistent.

I think the netlink scheme is saner, and the idea is to
transition people over to that.

We can't change what vconfig uses, so what Patrick decided
to do is pretty sane if you ask me.
