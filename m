From: Roger Quadros <rogerq@ti.com>
Subject: [PATCH 3/3] ARM: omap2plus_defconfig: Enable TI Ethernet PHY
Date: Tue, 14 Mar 2017 14:51:19 +0200
Message-ID: <f868e8aa-9b6e-0e96-299b-d7229ba4492c@ti.com>
References: <1489412554-2054-1-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <grygorii.strashko@ti.com>,
        <nsekhar@ti.com>, <jsarha@ti.com>, <linux-omap@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <tony@atomide.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489412554-2054-1-git-send-email-rogerq@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DP83848_PHY i.e. [TI TLK10X 10/100 Mbps PHY] is used on the
am335x-icev2 board. Enable the PHY driver for it.

Signed-off-by: Roger Quadros <rogerq@ti.com>
---
 arch/arm/configs/omap2plus_defconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/arm/configs/omap2plus_defconfig b/arch/arm/configs/omap2plus_defconfig
index f2462a6..cfa5bac 100644
--- a/arch/arm/configs/omap2plus_defconfig
+++ b/arch/arm/configs/omap2plus_defconfig
@@ -167,6 +167,7 @@ CONFIG_TI_CPTS=y
 # CONFIG_NET_VENDOR_VIA is not set
 # CONFIG_NET_VENDOR_WIZNET is not set
 CONFIG_AT803X_PHY=y
+CONFIG_DP83848_PHY=y
 CONFIG_MICREL_PHY=y
 CONFIG_SMSC_PHY=y
 CONFIG_USB_USBNET=m
-- 
2.7.4
