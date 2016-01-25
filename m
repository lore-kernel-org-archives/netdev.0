From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH net] lan78xx: changed to use updated
 phy-ignore-interrupts
Date: Mon, 25 Jan 2016 16:26:09 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D4049DBE4@CHN-SV-EXMX02.mchp-main.com>
References: <9235D6609DB808459E95D78E17F2E43D4049C34C@CHN-SV-EXMX02.mchp-main.com>
 <56A2F494.50900@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <f.fainelli@gmail.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp01.microchip.com ([198.175.253.37]:49990 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756463AbcAYQ0K convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2016 11:26:10 -0500
In-Reply-To: <56A2F494.50900@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian,

> Looks fine, just one nit below:
> 
> > @@ -954,6 +956,7 @@ static int lan78xx_link_reset(struct lan78xx_net
> *dev)
> >
> >  		ret = lan78xx_update_flowcontrol(dev, ecmd.duplex, ladv,
> radv);
> >  		netif_carrier_on(dev->net);
> 
> Do you need this netif_carrier_on() call here? PHYLIB should set that
> already.
> 
> > +		phy_mac_interrupt(phydev, 1);
> >  	}

Thanks for feedback.
As you pointed, netif_carrier_on() is redundant and also netif_carrier_off() in same routine.
Will post new patch.

Thanks,
Woojung
