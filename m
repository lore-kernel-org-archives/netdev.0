From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 0/3 net-next] bcm63xx_enet: add support for BCM63xx gigabit integrated switch
Date: Tue,  4 Jun 2013 22:53:32 +0100
Message-ID: <1370382815-17904-1-git-send-email-florian@openwrt.org>
Cc: ralf@linux-mips.org, blogic@openwrt.org, linux-mips@linux-mips.org,
	cernekee@gmail.com, mbizon@freebox.fr, jogo@openwrt.org,
	netdev@vger.kernel.org, Florian Fainelli <florian@openwrt.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:34581 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750935Ab3FDVxm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 17:53:42 -0400
Received: by mail-wi0-f182.google.com with SMTP id c10so678896wiw.15
        for <netdev@vger.kernel.org>; Tue, 04 Jun 2013 14:53:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David, Ralf,

This patchset contains changes to enable the BCM63xx gitabit integrated switch
found on BCM6328, BCM6362 and BCM6368 SoCs. It contains changes both to
arch/mips/bcm63xx and drivers/net/ethernet/bcm63xx_enet.c. The changes are
pretty difficult to split so I would rather see these merged via the net-tree.

(this time with netdev CC'd)

Thanks!

Maxime Bizon (3):
  bcm63xx_enet: implement reset autoneg ethtool callback
  bcm63xx_enet: split DMA channel register accesses
  bcm63xx_enet: add support for Broadcom BCM63xx integrated gigabit
    switch

 arch/mips/bcm63xx/boards/board_bcm963xx.c          |    4 +
 arch/mips/bcm63xx/dev-enet.c                       |  118 +-
 arch/mips/include/asm/mach-bcm63xx/bcm63xx_cpu.h   |    4 +-
 .../include/asm/mach-bcm63xx/bcm63xx_dev_enet.h    |   28 +
 arch/mips/include/asm/mach-bcm63xx/bcm63xx_regs.h  |   63 ++
 .../mips/include/asm/mach-bcm63xx/board_bcm963xx.h |    2 +
 drivers/net/ethernet/broadcom/bcm63xx_enet.c       | 1135 ++++++++++++++++++--
 drivers/net/ethernet/broadcom/bcm63xx_enet.h       |   75 ++
 8 files changed, 1331 insertions(+), 98 deletions(-)

-- 
1.7.10.4
