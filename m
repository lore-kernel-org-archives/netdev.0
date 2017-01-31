From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net/phy: fix phy_bcm_nsp_usb3.c build and kconfig
Date: Tue, 31 Jan 2017 13:23:27 -0500 (EST)
Message-ID: <20170131.132327.1409838716509830782.davem@davemloft.net>
References: <8b028a54-08a1-8e53-04ab-3fa8c51d2369@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yendapally.reddy@broadcom.com
To: rdunlap@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40656 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751353AbdAaSX3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 13:23:29 -0500
In-Reply-To: <8b028a54-08a1-8e53-04ab-3fa8c51d2369@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <rdunlap@infradead.org>
Date: Mon, 30 Jan 2017 17:02:44 -0800

> From: Randy Dunlap <rdunlap@infradead.org>
> 
> This driver uses mdio* (PHYLIB) interfaces, so it should select
> PHYLIB. PHYLIB depends on NETDEVICES to this driver should also
> depend on NETDEVICES.
> 
> Fixes these build errors:
> 
> drivers/built-in.o: In function `nsp_usb3_phy_init':
> phy-bcm-nsp-usb3.c:(.text+0x42d8): undefined reference to `mdiobus_write'
> phy-bcm-nsp-usb3.c:(.text+0x42f4): undefined reference to `mdiobus_write'
> phy-bcm-nsp-usb3.c:(.text+0x4310): undefined reference to `mdiobus_write'
> phy-bcm-nsp-usb3.c:(.text+0x432c): undefined reference to `mdiobus_write'
> phy-bcm-nsp-usb3.c:(.text+0x4348): undefined reference to `mdiobus_write'
> drivers/built-in.o:phy-bcm-nsp-usb3.c:(.text+0x437a): more undefined references to `mdiobus_write' follow
> drivers/built-in.o: In function `mdio_module_init':
> phy-bcm-nsp-usb3.c:(.init.text+0x1e1): undefined reference to `mdio_driver_register'
> drivers/built-in.o: In function `mdio_module_exit':
> phy-bcm-nsp-usb3.c:(.exit.text+0xae): undefined reference to `mdio_driver_unregister'
> 
> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>

This doesn't apply to the net-next tree, please respin.

Thanks.
