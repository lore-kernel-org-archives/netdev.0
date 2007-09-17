From: Robin Getz <rgetz@blackfin.uclinux.org>
Subject: Re: [PATCH 3/3] Blackfin EMAC driver: Add phyabstraction layer supporting in bfin_emac driver
Date: Sun, 16 Sep 2007 22:51:01 -0400
Message-ID: <200709162251.01558.rgetz@blackfin.uclinux.org>
References: <1189911475.9901.8.camel@roc-laptop>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: bryan.wu@analog.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754287AbXIQCuz@vger.kernel.org>
In-Reply-To: <1189911475.9901.8.camel@roc-laptop>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat 15 Sep 2007 22:57, Bryan Wu pondered:
> 
>  - add MDIO functions and register mdio bus
>  - add phy abstraction layer (PAL) functions and use PAL API
>  - test on STAMP537 board

Today, the Kconfig for the Blackfin just includes:

> config BFIN_MAC
>         tristate "Blackfin 536/537 on-chip mac support"
>         depends on NET_ETHERNET && (BF537 || BF536) && (!BF537_PORT_H)
>         select CRC32
>         select BFIN_MAC_USE_L1 if DMA_UNCACHED_NONE
>         help
>           This is the driver for blackfin on-chip mac device. Say Y if you
> want it compiled into the kernel. This driver is also available as a module
> ( = code which can be inserted in and removed from the running kernel
> whenever you want). The module will be called bfin_mac.

Since you are adding requirement for the PHYLIB with this patch, should there
be a select for that?

-Robin
