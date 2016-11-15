From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/2] net: ethernet: Allow Marvell & Freescale to COMPILE_TEST
Date: Tue, 15 Nov 2016 09:35:46 -0800
Message-ID: <20161115173548.32567-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, mw@semihalf.com, arnd@arndb.de,
        gregory.clement@free-electrons.com, Shaohui.Xie@freescale.com,
        Igal.Liberman@freescale.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33201 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750776AbcKORfy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 12:35:54 -0500
Received: by mail-pg0-f67.google.com with SMTP id 3so12323851pgd.0
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 09:35:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch series allows most of the Freescale Ethernet drivers to be built
with COMPILE_TEST and all Marvell drivers to build with COMPILE_TEST.

This is helpful to increase build coverage without requiring hacking into
Kconfig anymore.

Florian Fainelli (2):
  net: fsl: Allow most drivers to be built with COMPILE_TEST
  net: marvell: Allow drivers to be built with COMPILE_TEST

 drivers/net/ethernet/freescale/Kconfig | 3 ++-
 drivers/net/ethernet/marvell/Kconfig   | 8 ++++----
 2 files changed, 6 insertions(+), 5 deletions(-)

-- 
2.9.3
