From: "Robert P. J. Day" <rpjday@mindspring.com>
Subject: dead CONFIG_ variables:  drivers/net/
Date: Thu, 3 May 2007 07:48:01 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0705030746100.1924@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nic.NetDirect.CA ([216.16.235.2]:51675 "EHLO
	rubicon.netdirect.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031141AbXECLsY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 07:48:24 -0400
Received: from [192.168.1.100] (CPE000c419b52cd-CM001225dbafb6.cpe.net.cable.rogers.com [72.143.66.196])
	(authenticated bits=0)
	by rubicon.netdirect.ca (8.13.1/8.13.1) with ESMTP id l43BlxG2012805
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 3 May 2007 07:48:13 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


  as with the earlier post for net/, this is for drivers/net/.  once
again, there are clearly false positives but i'm sure there's
*something* in there that might need fixing.

========== ARCH_INNOKOM ==========
drivers/net/smc91x.h:145:#elif	defined(CONFIG_ARCH_INNOKOM) || \
arch/arm/tools/mach-types:275:innokom			ARCH_INNOKOM		INNOKOM			258
========== ARCH_RAMSES ==========
drivers/net/smc91x.h:148:	defined(CONFIG_ARCH_RAMSES)
arch/arm/tools/mach-types:252:mnci			ARCH_RAMSES		RAMSES			235
========== BCM947XX ==========
drivers/net/wireless/bcm43xx/bcm43xx_dma.c:663:#ifdef CONFIG_BCM947XX
drivers/net/wireless/bcm43xx/bcm43xx_main.h:36:#ifdef CONFIG_BCM947XX
drivers/net/wireless/bcm43xx/bcm43xx_main.c:64:#ifdef CONFIG_BCM947XX
drivers/net/wireless/bcm43xx/bcm43xx_main.c:145:#ifdef CONFIG_BCM947XX
drivers/net/wireless/bcm43xx/bcm43xx_main.c:789:#ifdef CONFIG_BCM947XX
drivers/net/wireless/bcm43xx/bcm43xx_main.c:799:#ifdef CONFIG_BCM947XX
drivers/net/wireless/bcm43xx/bcm43xx_main.c:1228:#ifdef CONFIG_BCM947XX
drivers/net/wireless/bcm43xx/bcm43xx_main.c:1390://FIXME: Do we _really_ want #ifndef CONFIG_BCM947XX here?
drivers/net/wireless/bcm43xx/bcm43xx_main.c:1392:#ifndef CONFIG_BCM947XX
drivers/net/wireless/bcm43xx/bcm43xx_main.c:2143:#ifdef CONFIG_BCM947XX
drivers/net/wireless/bcm43xx/bcm43xx_main.c:2155:#ifdef CONFIG_BCM947XX
drivers/net/wireless/bcm43xx/bcm43xx_main.c:2648:#ifdef CONFIG_BCM947XX
drivers/net/wireless/bcm43xx/bcm43xx_main.c:4147:#ifdef CONFIG_BCM947XX
drivers/net/wireless/bcm43xx/bcm43xx.h:661:#ifdef CONFIG_BCM947XX
drivers/net/wireless/bcm43xx/bcm43xx.h:792:#ifdef CONFIG_BCM947XX
========== CASSINI_MULTICAST_REG_WRITE ==========
drivers/net/cassini.c:3099:#ifdef CONFIG_CASSINI_MULTICAST_REG_WRITE
drivers/net/cassini.c:3169:#ifndef CONFIG_CASSINI_MULTICAST_REG_WRITE
========== CASSINI_NAPI ==========
drivers/net/cassini.c:107:#if defined(CONFIG_CASSINI_NAPI) && defined(HAVE_NETDEV_POLL)
========== CASSINI_QGE_DEBUG ==========
drivers/net/cassini.h:4362:#ifdef CONFIG_CASSINI_QGE_DEBUG
========== CHELSIO_T1_COUGAR ==========
drivers/net/chelsio/subr.c:188:#ifdef CONFIG_CHELSIO_T1_COUGAR
drivers/net/chelsio/subr.c:283:#if defined(CONFIG_CHELSIO_T1_1G) || defined(CONFIG_CHELSIO_T1_COUGAR)
drivers/net/chelsio/subr.c:323:#if defined(CONFIG_CHELSIO_T1_1G) || defined(CONFIG_CHELSIO_T1_COUGAR)
drivers/net/chelsio/subr.c:750:#ifdef CONFIG_CHELSIO_T1_COUGAR
drivers/net/chelsio/subr.c:1002:#ifdef CONFIG_CHELSIO_T1_COUGAR
drivers/net/chelsio/subr.c:1059:#ifdef CONFIG_CHELSIO_T1_COUGAR
drivers/net/chelsio/subr.c:1082:#ifdef CONFIG_CHELSIO_T1_COUGAR
========== ETRAX_NETWORK_RED_ON_NO_CONNECTION ==========
drivers/net/cris/eth_v10.c:1783:#if defined(CONFIG_ETRAX_NETWORK_RED_ON_NO_CONNECTION)
========== FIXED_MII_DUPLEX ==========
drivers/net/phy/fixed.c:335:#ifdef CONFIG_FIXED_MII_DUPLEX
========== GILBARCONAP ==========
drivers/net/fec.c:99:#elif defined(CONFIG_GILBARCONAP) || defined(CONFIG_SCALES)
========== LMC_IGNORE_HARDWARE_HANDSHAKE ==========
drivers/net/wan/lmc/lmc_media.c:33:#define CONFIG_LMC_IGNORE_HARDWARE_HANDSHAKE 1
drivers/net/wan/lmc/lmc_media.c:743:#ifdef CONFIG_LMC_IGNORE_HARDWARE_HANDSHAKE
========== MACH_LPD79520 ==========
drivers/net/smc91x.h:253:#elif   defined(CONFIG_MACH_LPD79520) \
arch/arm/mach-lh7a40x/lcd-panel.h:40:#if defined (MACH_LPD79520)\
arch/arm/tools/mach-types:553:lpd79520		MACH_LPD79520		LPD79520		537
========== MTD_KeyTechnology ==========
drivers/net/fec.c:101:#elif defined (CONFIG_MTD_KeyTechnology)
========== NETWINDER_RX_DMA_PROBLEMS ==========
drivers/net/irda/w83977af_ir.c:66:#define CONFIG_NETWINDER_RX_DMA_PROBLEMS /* Must have this one! */
drivers/net/irda/w83977af_ir.c:741:#ifdef CONFIG_NETWINDER_RX_DMA_PROBLEMS
drivers/net/irda/w83977af_ir.c:766:#ifdef CONFIG_NETWINDER_RX_DMA_PROBLEMS
drivers/net/irda/w83977af_ir.c:789:#ifdef CONFIG_NETWINDER_RX_DMA_PROBLEMS
========== NETWINDER_TX_DMA_PROBLEMS ==========
drivers/net/irda/w83977af_ir.c:65:#undef  CONFIG_NETWINDER_TX_DMA_PROBLEMS /* Not needed */
drivers/net/irda/w83977af_ir.c:593:#ifdef CONFIG_NETWINDER_TX_DMA_PROBLEMS
drivers/net/irda/w83977af_ir.c:609:#ifdef CONFIG_NETWINDER_TX_DMA_PROBLEMS
drivers/net/irda/w83977af_ir.c:625:#ifdef CONFIG_NETWINDER_TX_DMA_PROBLEMS
========== SBMAC_COALESCE ==========
drivers/net/sb1250-mac.c:58:#define CONFIG_SBMAC_COALESCE
drivers/net/sb1250-mac.c:97:#ifdef CONFIG_SBMAC_COALESCE
drivers/net/sb1250-mac.c:201:#ifdef CONFIG_SBMAC_COALESCE
drivers/net/sb1250-mac.c:696:#ifdef CONFIG_SBMAC_COALESCE
drivers/net/sb1250-mac.c:787:#ifdef CONFIG_SBMAC_COALESCE
drivers/net/sb1250-mac.c:828:#ifdef CONFIG_SBMAC_COALESCE
drivers/net/sb1250-mac.c:975:#ifdef CONFIG_SBMAC_COALESCE
drivers/net/sb1250-mac.c:1070:#ifndef CONFIG_SBMAC_COALESCE
drivers/net/sb1250-mac.c:1164:#ifdef CONFIG_SBMAC_COALESCE
drivers/net/sb1250-mac.c:1706:#ifdef CONFIG_SBMAC_COALESCE
drivers/net/sb1250-mac.c:2898:#ifdef CONFIG_SBMAC_COALESCE
========== SH_HICOSH4 ==========
drivers/net/cs89x0.h:440:#ifdef CONFIG_SH_HICOSH4
drivers/net/cs89x0.c:178:#elif defined(CONFIG_SH_HICOSH4)
drivers/net/cs89x0.c:570:#ifdef CONFIG_SH_HICOSH4
drivers/net/cs89x0.c:641:#ifdef CONFIG_SH_HICOSH4
drivers/net/cs89x0.c:726:#ifdef CONFIG_SH_HICOSH4 /* no EEPROM on HiCO, don't hazzle with it here */
drivers/net/cs89x0.c:1280:#if !defined(CONFIG_SH_HICOSH4) && !defined(CONFIG_ARCH_PNX010X) /* uses irq#1, so this won't work */
========== SIS190_NAPI ==========
drivers/net/sis190.c:50:#ifdef CONFIG_SIS190_NAPI
drivers/net/sis190.c:61:#ifdef CONFIG_SIS190_NAPI
========== USE_INTERNAL_TIMER ==========
drivers/net/irda/w83977af_ir.c:68:#undef  CONFIG_USE_INTERNAL_TIMER  /* Just cannot make that timer work */
drivers/net/irda/w83977af_ir.c:536:#ifdef CONFIG_USE_INTERNAL_TIMER
drivers/net/irda/w83977af_ir.c:563:#ifdef CONFIG_USE_INTERNAL_TIMER
drivers/net/irda/w83977af_ir.c:879:#ifdef CONFIG_USE_INTERNAL_TIMER
========== USE_W977_PNP ==========
drivers/net/irda/w83977af_ir.c:69:#define CONFIG_USE_W977_PNP        /* Currently needed */
drivers/net/irda/w83977af_ir.c:283:#ifdef CONFIG_USE_W977_PNP
drivers/net/irda/w83977af_ir.c:293:#endif /* CONFIG_USE_W977_PNP */
drivers/net/irda/w83977af_ir.c:323:#ifdef CONFIG_USE_W977_PNP
drivers/net/irda/w83977af_ir.c:349:#endif /* CONFIG_USE_W977_PNP */

rday
-- 
========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://fsdev.net/wiki/index.php?title=Main_Page
========================================================================
