From: Alexandre TORGUE <alexandre.torgue@gmail.com>
Subject: [PATCH v2 4/4] ARM: STM32: Enable Ethernet in stm32_defconfig
Date: Tue, 23 Feb 2016 16:10:44 +0100
Message-ID: <1456240244-10275-5-git-send-email-alexandre.torgue@gmail.com>
References: <1456240244-10275-1-git-send-email-alexandre.torgue@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Maxime Coquelin <mcoquelin.stm32@gmail.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:33039 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754052AbcBWPKx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 10:10:53 -0500
In-Reply-To: <1456240244-10275-1-git-send-email-alexandre.torgue@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable basic Ethernet support (IPV4) for stm32 defconfig.

Signed-off-by: Alexandre TORGUE <alexandre.torgue@gmail.com>

diff --git a/arch/arm/configs/stm32_defconfig b/arch/arm/configs/stm32_defconfig
index ec52505..8b8abe0 100644
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
