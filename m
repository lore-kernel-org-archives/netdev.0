From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH, RFC] Extend smc911x to support LAN921x chips
Date: Sat, 11 Oct 2008 09:22:36 +0200
Message-ID: <871vynr3yb.fsf@macbook.be.48ers.dk>
References: <OFFEAB9876.D4A121DB-ON802574BF.0052D905-802574BF.0054D4AE@smsc.com>
	<87vdx5gjzo.fsf@macbook.be.48ers.dk>
	<Pine.LNX.4.64.0810110125540.10196@axis700.grange>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve.Glendinning@smsc.com, netdev@vger.kernel.org,
	Ian.Saturley@smsc.com
To: Guennadi Liakhovetski <lg@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:45860 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750816AbYJKHWm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2008 03:22:42 -0400
Received: by ey-out-2122.google.com with SMTP id 6so344772eyi.37
        for <netdev@vger.kernel.org>; Sat, 11 Oct 2008 00:22:40 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0810110125540.10196@axis700.grange> (Guennadi Liakhovetski's message of "Sat\, 11 Oct 2008 01\:33\:17 +0200 \(CEST\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Guennadi" == Guennadi Liakhovetski <lg@denx.de> writes:

Hi,

 Guennadi> LAN921x controllers from SMSC register cmpatible with
 Guennadi> LAN911x chips, the driver only needs to recognise
 Guennadi> respective chip IDs. Patch also adds network support for
 Guennadi> the pcm037 board, using this chip.

 Guennadi> Signed-off-by: Guennadi Liakhovetski <lg@denx.de>

 Guennadi> ---

 Guennadi> This is an RFC just to let everyone comment on it, it
 Guennadi> probably would also be better to split it into two patches
 Guennadi> - one only for drivers/net and one for arch/arm plus the
 Guennadi> Kconfig hunk. Based on 2.6.27, would be nice to get it into
 Guennadi> 2.6.28. The CC-list is kept from the previous discussion
 Guennadi> regarding this driver-extension.

It looks good, but you should definately split out the arm and cleanup
stuff from the new IDs.

 Guennadi> @@ -722,6 +724,9 @@ static void smc911x_phy_detect(struct net_device *dev)
 Guennadi>  						break;
 Guennadi>  					}
 Guennadi>  				}
 Guennadi> +				if (phyaddr < 32)
 Guennadi> +					/* Found an external PHY */
 Guennadi> +					break;

What's this for? Isn't that handled just above?

-- 
Bye, Peter Korsgaard
