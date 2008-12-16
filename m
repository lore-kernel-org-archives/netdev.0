From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH 0/14] gianfar improvements
Date: Tue, 16 Dec 2008 17:20:53 -0600
Message-ID: <1229469667-25002-1-git-send-email-afleming@freescale.com>
Cc: galak@kernel.crashing.org, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:39714 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753811AbYLPXVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 18:21:24 -0500
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id mBGNL9ar013524
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2008 16:21:13 -0700 (MST)
Received: from ld0175-tx32.am.freescale.net (ld0175-tx32.am.freescale.net [10.82.19.125])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id mBGNL84x017590
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2008 17:21:08 -0600 (CST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many improvements have been made to the gianfar driver, including converting it
to be an OF driver, and adding support for scatter-gather

 b/Documentation/powerpc/dts-bindings/fsl/tsec.txt |   12 
 b/arch/powerpc/boot/dts/asp834x-redboot.dts       |   20 
 b/arch/powerpc/boot/dts/ksi8560.dts               |   20 
 b/arch/powerpc/boot/dts/mpc8313erdb.dts           |   20 
 b/arch/powerpc/boot/dts/mpc8315erdb.dts           |   19 
 b/arch/powerpc/boot/dts/mpc8349emitx.dts          |   18 
 b/arch/powerpc/boot/dts/mpc8349emitxgp.dts        |    5 
 b/arch/powerpc/boot/dts/mpc834x_mds.dts           |   19 
 b/arch/powerpc/boot/dts/mpc8377_mds.dts           |   19 
 b/arch/powerpc/boot/dts/mpc8377_rdb.dts           |   19 
 b/arch/powerpc/boot/dts/mpc8378_mds.dts           |   19 
 b/arch/powerpc/boot/dts/mpc8378_rdb.dts           |   17 
 b/arch/powerpc/boot/dts/mpc8379_mds.dts           |   18 
 b/arch/powerpc/boot/dts/mpc8379_rdb.dts           |   18 
 b/arch/powerpc/boot/dts/mpc8536ds.dts             |   18 
 b/arch/powerpc/boot/dts/mpc8540ads.dts            |   31 
 b/arch/powerpc/boot/dts/mpc8541cds.dts            |   18 
 b/arch/powerpc/boot/dts/mpc8544ds.dts             |   20 
 b/arch/powerpc/boot/dts/mpc8548cds.dts            |   44 +
 b/arch/powerpc/boot/dts/mpc8555cds.dts            |   18 
 b/arch/powerpc/boot/dts/mpc8560ads.dts            |   18 
 b/arch/powerpc/boot/dts/mpc8568mds.dts            |   18 
 b/arch/powerpc/boot/dts/mpc8572ds.dts             |   45 +
 b/arch/powerpc/boot/dts/mpc8641_hpcn.dts          |   45 +
 b/arch/powerpc/boot/dts/sbc8349.dts               |   18 
 b/arch/powerpc/boot/dts/sbc8548.dts               |   18 
 b/arch/powerpc/boot/dts/sbc8560.dts               |   18 
 b/arch/powerpc/boot/dts/sbc8641d.dts              |   44 +
 b/arch/powerpc/boot/dts/stx_gp3_8560.dts          |   18 
 b/arch/powerpc/boot/dts/tqm8540.dts               |   28 
 b/arch/powerpc/boot/dts/tqm8541.dts               |   18 
 b/arch/powerpc/boot/dts/tqm8548-bigflash.dts      |   44 +
 b/arch/powerpc/boot/dts/tqm8548.dts               |   44 +
 b/arch/powerpc/boot/dts/tqm8555.dts               |   18 
 b/arch/powerpc/boot/dts/tqm8560.dts               |   18 
 b/arch/powerpc/sysdev/fsl_soc.c                   |  241 ------
 b/drivers/net/gianfar.c                           |   14 
 b/drivers/net/gianfar.h                           |   21 
 b/drivers/net/gianfar_ethtool.c                   |   22 
 b/drivers/net/gianfar_mii.c                       |  212 +++--
 b/drivers/net/gianfar_mii.h                       |    2 
 b/include/linux/fsl_devices.h                     |   18 
 drivers/net/gianfar.c                             |  863 +++++++++++++---------
 drivers/net/gianfar.h                             |   57 +
 drivers/net/gianfar_ethtool.c                     |   67 -
 45 files changed, 1599 insertions(+), 722 deletions(-)


