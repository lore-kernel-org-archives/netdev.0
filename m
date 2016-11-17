From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v4 0/5] net: Enable COMPILE_TEST for Marvell & Freescale drivers
Date: Thu, 17 Nov 2016 11:19:09 -0800
Message-ID: <20161117191914.11077-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, mw@semihalf.com, arnd@arndb.de,
        gregory.clement@free-electrons.com, Shaohui.Xie@freescale.com,
        andrew@lunn.ch, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36181 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752463AbcKQTUs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 14:20:48 -0500
Received: by mail-pg0-f67.google.com with SMTP id x23so18292047pgx.3
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2016 11:20:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series allows building the Freescale and Marvell Ethernet network
drivers with COMPILE_TEST.

Changes in v4:

- add proper HAS_DMA to fix build errors on m32r
- provide an inline stub for mvebu_mbus_get_dram_win_info
- added an additional patch to fix build errors with mv88e6xxx on m32r

Changes in v3:

- reorder patches to avoid introducing a build warning between commits

Changes in v2:

- rename register define clash when building for i386 (spotted by LKP)


Florian Fainelli (5):
  net: gianfar_ptp: Rename FS bit to FIPERST
  net: fsl: Allow most drivers to be built with COMPILE_TEST
  bus: mvebu-bus: Provide inline stub for mvebu_mbus_get_dram_win_info
  net: marvell: Allow drivers to be built with COMPILE_TEST
  net: dsa: mv88e6xxx: Select IRQ_DOMAIN

 drivers/net/dsa/mv88e6xxx/Kconfig            |  1 +
 drivers/net/ethernet/freescale/Kconfig       |  4 +++-
 drivers/net/ethernet/freescale/gianfar_ptp.c |  4 ++--
 drivers/net/ethernet/marvell/Kconfig         | 11 +++++++----
 include/linux/mbus.h                         |  8 ++++++++
 5 files changed, 21 insertions(+), 7 deletions(-)

-- 
2.9.3
