From: "Nicu Ioan Petru" <ionut.nicu@freescale.com>
Subject: RE: [PATCH][v2] phylib: add module owner to the mii_bus structure
Date: Mon, 21 Jan 2008 12:13:20 -0000
Message-ID: <53E7C5BEAA4B474B8FB3E84A70C00E1B01E63486@zuk35exm20.fsl.freescale.net>
References: <20071221153713.641f010e@deepthought> <78b2dab672856274c518f4c523f6f63f59f06dd1.1198861866.git.ionut.nicu@freescale.com> <CFE6E252-4CB9-4F91-ABE6-330798408E50@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <shemminger@linux-foundation.org>
To: "Fleming Andy" <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:56392 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753693AbYAUMNb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 07:13:31 -0500
Received: from az33smr02.freescale.net (az33smr02.freescale.net [10.64.34.200])
	by az33egw02.freescale.net (8.12.11/az33egw02) with ESMTP id m0LCDMVF004163
	for <netdev@vger.kernel.org>; Mon, 21 Jan 2008 05:13:22 -0700 (MST)
Received: from zuk35exm20.fsl.freescale.net (zuk35exm20.ea.freescale.net [10.210.1.54])
	by az33smr02.freescale.net (8.13.1/8.13.0) with ESMTP id m0LCDLvX022672
	for <netdev@vger.kernel.org>; Mon, 21 Jan 2008 06:13:22 -0600 (CST)
Content-class: urn:content-classes:message
In-Reply-To: <CFE6E252-4CB9-4F91-ABE6-330798408E50@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Fleming Andy 
> Sent: Monday, January 14, 2008 8:56 PM
> To: Nicu Ioan Petru
> Cc: netdev@vger.kernel.org; shemminger@linux-foundation.org
> Subject: Re: [PATCH][v2] phylib: add module owner to the 
> mii_bus structure
>
> Any reason you didn't update the other drivers?
> 
>  > git grep mdiobus_register drivers/net/          // duplicates and  
> mdio_bus.c edited out
> drivers/net/au1000_eth.c:       mdiobus_register(&aup->mii_bus);
> drivers/net/bfin_mac.c: mdiobus_register(&lp->mii_bus);
> drivers/net/cpmac.c:    res = mdiobus_register(&cpmac_mii);
> drivers/net/fec_mpc52xx_phy.c:  err = mdiobus_register(bus);
> drivers/net/fs_enet/mii-bitbang.c:      ret = 
> mdiobus_register(new_bus);
> drivers/net/fs_enet/mii-fec.c:  ret = mdiobus_register(new_bus);
> drivers/net/gianfar_mii.c:      err = mdiobus_register(new_bus);
> drivers/net/macb.c:     if (mdiobus_register(&bp->mii_bus))
> drivers/net/sb1250-mac.c:       err = mdiobus_register(&sc->mii_bus);
> drivers/net/ucc_geth_mii.c:     err = mdiobus_register(new_bus);
> 
> I'm guessing this was only tested on the UEC, because unless 
> I misunderstand the code, any other driver would now crash 
> when you try to get the owner.
> 

That's not true. If you look closely at the implementation of
try_module_get(), you'll see it returns 1 when module is NULL. So my
change should make no difference for the other drivers.

If that's really a concern for you, I can update the other drivers as
well. How do you propose to do this? Resubmit this patch or send a new
one?

Ionut.
 
