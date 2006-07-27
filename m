From: Andy Gay <andy@andynet.net>
Subject: Re: ipsec tunnel policy vs routing table
Date: Thu, 27 Jul 2006 11:59:16 -0400
Message-ID: <1154015956.16424.20.camel@tahini.andynet.net>
References: <BAY103-F465E15C95576093DD78A3B2580@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms040pub.verizon.net ([206.46.252.40]:20691 "EHLO
	vms040pub.verizon.net") by vger.kernel.org with ESMTP
	id S1750816AbWG0P7c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jul 2006 11:59:32 -0400
Received: from andyhp.tranquilitynj.net ([70.18.168.191])
 by vms040.mailsrvcs.net
 (Sun Java System Messaging Server 6.2-4.02 (built Sep  9 2005))
 with ESMTPA id <0J3200JCBKEUFE9E@vms040.mailsrvcs.net> for
 netdev@vger.kernel.org; Thu, 27 Jul 2006 10:59:19 -0500 (CDT)
In-reply-to: <BAY103-F465E15C95576093DD78A3B2580@phx.gbl>
To: Marco Berizzi <pupilla@hotmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-07-27 at 17:25 +0200, Marco Berizzi wrote:
> Andy Gay wrote:
> 
> >As Herbert said, the right= address doesn't matter. Search for 10.180.
> 
> If it doesn't matter, who told to linux to send packets for
> 10.180.0.0/16 to 172.16.1.253?

You're confusing routing with IPsec policy.

Your routing table determines where packets are sent.

The IPsec policy determines which packets are processed by IPsec. If
packets match the policy and are encapsulated in a tunnel, the new
packets will have different source/dest addresses which will then be
forwarded according to the routing table.


> 
> >BTW - in your erlier mail you had "rightsubnet=10.180.0./16". Looks like
> >a typo there.
> 
> yes it was a typo.
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

