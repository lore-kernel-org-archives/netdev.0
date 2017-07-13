From: Abhishek Shah <abhishek.shah@broadcom.com>
Subject: [PATCH 0/3] Extend BGMAC driver for Stingray SoC
Date: Fri, 14 Jul 2017 00:34:06 +0530
Message-ID: <1499972649-6200-1-git-send-email-abhishek.shah@broadcom.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
        bcm-kernel-feedback-list@broadcom.com,
        Abhishek Shah <abhishek.shah@broadcom.com>
To: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <rafal@milecki.pl>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Jon Mason <jon.mason@broadcom.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patchset extends Broadcom BGMAC driver for Broadcom Stingray SoC.

This patchset is based on Linux-4.12 and tested on NS2 and Stingray.

Abhishek Shah (3):
  net: ethernet: bgmac: Remove unnecessary 'return' from
    platform_bgmac_idm_write
  net: ethernet: bgmac: Make IDM register space optional in BGMAC driver
  Documentation: devicetree: net: optional idm regs for bgmac

 .../devicetree/bindings/net/brcm,amac.txt          |  1 +
 drivers/net/ethernet/broadcom/bgmac-platform.c     | 21 ++++---
 drivers/net/ethernet/broadcom/bgmac.c              | 70 +++++++++++++---------
 drivers/net/ethernet/broadcom/bgmac.h              |  1 +
 4 files changed, 57 insertions(+), 36 deletions(-)

-- 
2.7.4
