From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 0/3] net: ethernet: Allow Marvell & Freescale to COMPILE_TEST
Date: Tue, 15 Nov 2016 16:40:32 -0800
Message-ID: <20161116004037.20941-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, mw@semihalf.com, arnd@arndb.de,
        gregory.clement@free-electrons.com, Shaohui.Xie@freescale.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34661 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750815AbcKPAkn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 19:40:43 -0500
Received: by mail-pf0-f194.google.com with SMTP id y68so8730056pfb.1
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 16:40:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch series allows most of the Freescale Ethernet drivers to be built
with COMPILE_TEST and all Marvell drivers to build with COMPILE_TEST.

This is helpful to increase build coverage without requiring hacking into
Kconfig anymore.

Changes in v3:

- reorder patches to avoid introducing a build warning between commits

Changes in v2:

- rename register define clash when building for i386 (spotted by LKP)

Florian Fainelli (3):
  net: gianfar_ptp: Rename FS bit to FIPERST
  net: fsl: Allow most drivers to be built with COMPILE_TEST
  net: marvell: Allow drivers to be built with COMPILE_TEST

 drivers/net/ethernet/freescale/Kconfig       | 3 ++-
 drivers/net/ethernet/freescale/gianfar_ptp.c | 4 ++--
 drivers/net/ethernet/marvell/Kconfig         | 8 ++++----
 3 files changed, 8 insertions(+), 7 deletions(-)

-- 
2.9.3
