From: "David S. Miller" <davem@davemloft.net>
Subject: Re: determine outgoing interface (eth0,eth1) for a packet
 according to the dest IP
Date: Tue, 25 Apr 2006 00:58:31 -0700 (PDT)
Message-ID: <20060425.005831.64868698.davem@davemloft.net>
References: <ada605fb0604250031r2e4a74e7id0b5079fabde9517@mail.gmail.com>
	<200604250943.49422.ak@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: qwejohn@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:61652
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751414AbWDYH6m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Apr 2006 03:58:42 -0400
To: ak@suse.de
In-Reply-To: <200604250943.49422.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@suse.de>
Date: Tue, 25 Apr 2006 09:43:49 +0200

> On Tuesday 25 April 2006 09:31, John Que wrote:
> > Hello,
> > What is the right way to determine on which interface card
> > (eth0 or eth1) will a packet be sent (according to the dest IP)?
> 
> You can send a rtnetlink RTM_GETROUTE message to ask the kernel.
> Result is the interface index in RTA_OIF, which can be converted
> into a name.

That scheme does not handle netfilter nor packet scheduler
classifier mangling and redirection of the packet.
