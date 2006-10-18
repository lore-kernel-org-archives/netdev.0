From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Ethernet Cheap Cryptography
Date: Wed, 18 Oct 2006 03:16:29 -0700 (PDT)
Message-ID: <20061018.031629.88703132.davem@davemloft.net>
References: <17717.40394.531846.695392@localhost.localdomain>
	<20061017.202544.74747614.davem@davemloft.net>
	<200610181151.46506.dpc@asn.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@dino.dnsalias.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:31633
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030177AbWJRKQW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Oct 2006 06:16:22 -0400
To: dpc@asn.pl
In-Reply-To: <200610181151.46506.dpc@asn.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dawid Ciezarkiewicz <dpc@asn.pl>
Date: Wed, 18 Oct 2006 11:51:46 +0200

> I've tried to put ccrypt handlers as close to hardware xmit and recv as 
> possible so local reorder doesn't matter. Medium doesn't reorder frames and 
> switches, bridges shouldn't do that neither (but as Stephen J. Bevan said 
> this may not be always true).

You can put it all the way in netif_receive_skb() and you still
can see reordering of receive packets on an SMP system.
