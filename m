From: Stephen Boyd <sboyd@codeaurora.org>
Subject: [PATCH 0/5] ks8851 MAC and eeprom updates
Date: Mon, 21 Nov 2011 10:57:55 -0800
Message-ID: <1321901880-12883-1-git-send-email-sboyd@codeaurora.org>
Cc: linux-kernel@vger.kernel.org, Sebastien Jan <s-jan@ti.com>,
	Ben Dooks <ben@simtec.co.uk>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I pulled this patch series off the netdev list[1] when the eeprom
reading didn't work for my ks8851 and I wanted the mac address to be
read out at boot. It all seems to work well, so I'm posting it here
again, slightly cleaned up and simplified, for inclusion.

Overall it reduces the lines of code and properly supports eeprom
reading; two things the previous implementation doesn't do.

This is based off of linux-next-20111025.

Thanks to Ben Dooks for doing the heavy lifting.

[1] http://article.gmane.org/gmane.linux.network/159708

Ben Dooks (4):
  eeprom_93cx6: Add data direction control.
  eeprom_93cx6: Add write support
  KSZ8851-SNL: Add support for EEPROM MAC address
  KSZ8851-SNL: Add ethtool support for EEPROM via eeprom_93cx6

Tristram Ha (1):
  KSZ8851-SNL: Fix MAC address change problem

 drivers/misc/eeprom/eeprom_93cx6.c   |   88 ++++++
 drivers/net/ethernet/micrel/Kconfig  |    2 +
 drivers/net/ethernet/micrel/ks8851.c |  513 ++++++++++++----------------------
 drivers/net/ethernet/micrel/ks8851.h |   15 +-
 include/linux/eeprom_93cx6.h         |    8 +
 5 files changed, 278 insertions(+), 348 deletions(-)
-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.
