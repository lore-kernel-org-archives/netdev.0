From: Alexandre TORGUE <alexandre.torgue@gmail.com>
Subject: [PATCH v6 4/6] ARM: STM32: Enable Ethernet in stm32_defconfig
Date: Mon, 25 Apr 2016 13:54:00 +0200
Message-ID: <1461585242-32401-5-git-send-email-alexandre.torgue@gmail.com>
References: <1461585242-32401-1-git-send-email-alexandre.torgue@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	robh@kernel.org, manabian@gmail.com, wens@csie.org
To: Maxime Coquelin <mcoquelin.stm32@gmail.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org, devicetree@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461585242-32401-1-git-send-email-alexandre.torgue@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Enable basic Ethernet support (IPV4) for stm32 defconfig.

Signed-off-by: Alexandre TORGUE <alexandre.torgue@gmail.com>

diff --git a/arch/arm/configs/stm32_defconfig b/arch/arm/configs/stm32_defconfig
index 1e5ec2a..719218b 100644
--- a/arch/arm/configs/stm32_defconfig
+++ b/arch/arm/configs/stm32_defconfig
@@ -33,11 +33,20 @@ CONFIG_XIP_PHYS_ADDR=0x08008000
 CONFIG_BINFMT_FLAT=y
 CONFIG_BINFMT_SHARED_FLAT=y
 # CONFIG_COREDUMP is not set
+CONFIG_NET=y
+CONFIG_INET=y
+# CONFIG_INET_XFRM_MODE_TRANSPORT is not set
+# CONFIG_INET_XFRM_MODE_TUNNEL is not set
+# CONFIG_INET_XFRM_MODE_BEET is not set
+# CONFIG_IPV6 is not set
 CONFIG_DEVTMPFS=y
 CONFIG_DEVTMPFS_MOUNT=y
 # CONFIG_FW_LOADER is not set
 # CONFIG_BLK_DEV is not set
 CONFIG_EEPROM_93CX6=y
+CONFIG_NETDEVICES=y
+CONFIG_STMMAC_ETH=y
+# CONFIG_WLAN is not set
 # CONFIG_INPUT is not set
 # CONFIG_SERIO is not set
 # CONFIG_VT is not set
-- 
1.9.1
