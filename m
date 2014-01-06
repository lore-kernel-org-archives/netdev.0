From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 0/6] phylib: cleanups
Date: Mon, 6 Jan 2014 09:35:42 +0100
Message-ID: <20140106083542.GA4897@netboy>
References: <201401040413.06853.sergei.shtylyov@cogentembedded.com>
 <20140104155338.GG4925@netboy>
 <52C8417D.6020502@cogentembedded.com>
 <52C858C7.1010300@cogentembedded.com>
 <20140105083109.GB4933@netboy>
 <52C960B8.1020607@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:38878 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751758AbaAFIfs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 03:35:48 -0500
Received: by mail-ea0-f174.google.com with SMTP id b10so7599620eae.5
        for <netdev@vger.kernel.org>; Mon, 06 Jan 2014 00:35:47 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <52C960B8.1020607@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 05, 2014 at 05:40:08PM +0400, Sergei Shtylyov wrote:
> On 05-01-2014 12:31, Richard Cochran wrote:
> >After all, there are not that many phylib drivers.
> 
>    Really? I find the number to be intimidating enough to not do the
> cleanups on them also in this same patchset. Anyway, the callback
> was intended for the Ethernet drivers.

I once made a list using cscope, in order find all phylib drivers that
are missing skb_tx_timestamp. Here is what I came up with at that
time. Discounting those files under 'phylib' and 'unlikely', I only
found 30 drivers.

Finding files #including file: linux/phy.h

* arm
  drivers/net/arm/ixp4xx_eth.c
  drivers/net/davinci_emac.c
  drivers/net/macb.c
  drivers/net/pxa168_eth.c
  drivers/net/ax88796.c
  drivers/net/smsc911x.c
* powerpc
  drivers/net/fec_mpc52xx.c
  drivers/net/fs_enet/fs_enet-main.c
  drivers/net/ll_temac_main.c
  drivers/net/mv643xx_eth.c
  drivers/net/ucc_geth.c
  drivers/net/xilinx_emaclite.c
* x86
  drivers/net/dnet.c
  drivers/net/ethoc.c
  drivers/net/fec.c
  drivers/net/r6040.c
  drivers/net/smsc9420.c
  drivers/net/stmmac/stmmac_main.c
  drivers/net/tg3.c
* mips
  drivers/net/au1000_eth.c
  drivers/net/bcm63xx_enet.h
  drivers/net/cpmac.c
  drivers/net/lantiq_etop.c
  drivers/net/octeon/octeon_mgmt.c
  drivers/net/sb1250-mac.c
  drivers/net/tc35815.c
* sparc
  drivers/net/greth.h
* superh
  drivers/net/sh_eth.c
  drivers/net/sh_eth.h
* xtensa
  drivers/net/s6gmac.c
* phylib
  drivers/net/phy/bcm63xx.c
  drivers/net/phy/broadcom.c
  drivers/net/phy/cicada.c
  drivers/net/phy/davicom.c
  drivers/net/phy/dp83640.c
  drivers/net/phy/et1011c.c
  drivers/net/phy/fixed.c
  drivers/net/phy/icplus.c
  drivers/net/phy/lxt.c
  drivers/net/phy/marvell.c
  drivers/net/phy/mdio-octeon.c
  drivers/net/phy/mdio_bus.c
  drivers/net/phy/micrel.c
  drivers/net/phy/national.c
  drivers/net/phy/phy.c
  drivers/net/phy/phy_device.c
  drivers/net/phy/qsemi.c
  drivers/net/phy/realtek.c
  drivers/net/phy/smsc.c
  drivers/net/phy/ste10Xp.c
  drivers/net/phy/vitesse.c
* unlikely
  drivers/net/pasemi_mac.h
  drivers/of/of_mdio.c
  drivers/staging/octeon/ethernet-mdio.c
  drivers/staging/octeon/ethernet-rgmii.c
  drivers/staging/octeon/ethernet.c
  include/linux/bfin_mac.h
  include/linux/fec.h
  include/linux/mdio-bitbang.h
  include/linux/of_mdio.h
  include/linux/smsc911x.h
  net/core/timestamping.c
  net/dsa/dsa_priv.h
  net/dsa/mv88e6060.c
  net/dsa/mv88e6123_61_65.c
  net/dsa/mv88e6131.c
  net/dsa/mv88e6xxx.c
  net/dsa/slave.c
 
>    Thanks I found those eventually. However, my LinkedIn account
> told me that Andy left Freescale about that time (it also gave up
> his private email though).

Okay, so you know more than I do.

Thanks,
Richard
