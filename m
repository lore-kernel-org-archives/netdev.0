From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 11/47] Bluetooth: Fix Kconfig for Marvell Bluetooth driver
Date: Sun, 30 Aug 2009 01:50:25 -0700
Message-ID: <e7a25f9839fd392ec2c96e7e2b3734501d761a24.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
 <fd0b3ff707dc1f7837079044bd4eca7ed505f70d.1251621661.git.marcel@holtmann.org>
 <981b1414d78a7a42cab48b97d4de54a62d61db88.1251621661.git.marcel@holtmann.org>
 <290ba200815fdecb4d40dc942499c4ea6d0c4624.1251621661.git.marcel@holtmann.org>
 <364f63519d94442ed373ac7da79033c8282df46a.1251621661.git.marcel@holtmann.org>
 <9eba32b86d17ef87131fa0bce43c614904ab5781.1251621661.git.marcel@holtmann.org>
 <edad63886993d18ab800c49f6587a93432ef8b35.1251621661.git.marcel@holtmann.org>
 <132ff4e5fa8dfb71a7d99902f88043113947e972.1251621661.git.marcel@holtmann.org>
 <789221ecc870117b77e354d488d5d29f15410de8.1251621661.git.marcel@holtmann.org>
 <fb784f0508d5aa39a23e72879a8dfb517c6f6e7f.1251621661.git.marcel@holtmann.org>
 <196be0cd018068d545e1d764094c7b07aaf0bcfe.1251621661.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53276 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752874AbZH3IwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 04:52:03 -0400
In-Reply-To: <196be0cd018068d545e1d764094c7b07aaf0bcfe.1251621661.git.marcel@holtmann.org>
In-Reply-To: <cover.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Marvell driver selects DEBUG_FS and FW_LOADER for its core driver
and that is pointless. Don't select DEBUG_FS since it is either enabled
or not and it is not for the driver to enable it. Also FW_LOADER is
only used within the SDIO driver and so just have that one select the
FW_LOADER option.

Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 drivers/bluetooth/Kconfig |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/bluetooth/Kconfig b/drivers/bluetooth/Kconfig
index 5f04014..652367a 100644
--- a/drivers/bluetooth/Kconfig
+++ b/drivers/bluetooth/Kconfig
@@ -172,8 +172,6 @@ config BT_HCIVHCI
 
 config BT_MRVL
 	tristate "Marvell Bluetooth driver support"
-	select FW_LOADER
-	select DEBUG_FS
 	help
 	  The core driver to support Marvell Bluetooth devices.
 
@@ -186,6 +184,7 @@ config BT_MRVL
 config BT_MRVL_SDIO
 	tristate "Marvell BT-over-SDIO driver"
 	depends on BT_MRVL && MMC
+	select FW_LOADER
 	help
 	  The driver for Marvell Bluetooth chipsets with SDIO interface.
 
-- 
1.6.2.5

