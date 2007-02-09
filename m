From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] [000]  dmfe : fix bugs and add features
Date: Fri, 09 Feb 2007 16:15:26 -0500
Message-ID: <45CCE46E.9010902@garzik.org>
References: <96797.60132.qm@web38511.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, tori@unhappy.mine.nu,
	netdev@vger.kernel.org,
	Samuel Thibault <samuel.thibault@ens-lyon.org>
To: Levitsky Maxim <maximlevitsky@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60368 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752308AbXBIVPb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Feb 2007 16:15:31 -0500
In-Reply-To: <96797.60132.qm@web38511.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Levitsky Maxim wrote:
> Hello,
> 
> Before some time I decided to fix suspend/resume on my Davicom network card.
> During development I also fixed couple of bugs and added support for link detection and WOL
> Note : 2.6.20 already has support for link detection , but it is broken when card has external PHY
> , like mine.
> 
> So here it goes:
> 
> [PATCH] [NET] [001] dmfe : trivial/spelling fixes
> [PATCH] [NET] [002] dmfe : Fix possible oops
> [PATCH] [NET] [003] dmfe : fix link detection
> [PATCH] [NET] [004] dmfe : Add suspend/resume support
> [PATCH] [NET] [005] dmfe : Add support for wake-on-lan
> 
>         Maxim Levitsky
> 
> 
>  
> ____________________________________________________________________________________
> Finding fabulous fares is fun.  
> Let Yahoo! FareChase search your favorite travel sites to find flight and hotel bargains.
> http://farechase.yahoo.com/promo-generic-14795097
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
What about the above report?

I would rather fix this first, before applying more patches on top of a 
problematic patch...

> Commit 7628b0a8c01a02966d2228bdf741ddedb128e8f8 (drivers/net/tulip/dmfe: 
> support basic carrier detection) breaks networking on my Davicom DM9009. 
> ethtool always reports there is no link.  tcpdump shows incoming 
> packets, but TX is disabled.  Reverting the above patch fixes the 
> problem.

Regards,

	Jeff




