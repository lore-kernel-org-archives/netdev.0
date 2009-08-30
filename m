From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 13/47] Bluetooth: Remove pointless ifdef protection for Marvell header files
Date: Sun, 30 Aug 2009 01:50:27 -0700
Message-ID: <944fe798c6a48336e82bbc0d4e280587325a4d95.1251621661.git.marcel@holtmann.org>
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
 <e7a25f9839fd392ec2c96e7e2b3734501d761a24.1251621661.git.marcel@holtmann.org>
 <08b0b0ce8c609b0e2284b134f0614e211374a038.1251621661.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53282 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752893AbZH3IwG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 04:52:06 -0400
In-Reply-To: <08b0b0ce8c609b0e2284b134f0614e211374a038.1251621661.git.marcel@holtmann.org>
In-Reply-To: <cover.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both header files of the Marvell Bluetooth driver are private anyway and
if the driver happens to include them twice or they create a circular
dependency then the driver needs fixing. So just remove both pointless
ifdefs.

Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 drivers/bluetooth/btmrvl_drv.h  |    5 -----
 drivers/bluetooth/btmrvl_sdio.h |    5 -----
 2 files changed, 0 insertions(+), 10 deletions(-)

diff --git a/drivers/bluetooth/btmrvl_drv.h b/drivers/bluetooth/btmrvl_drv.h
index 7a12f68..5da3be4 100644
--- a/drivers/bluetooth/btmrvl_drv.h
+++ b/drivers/bluetooth/btmrvl_drv.h
@@ -19,9 +19,6 @@
  *
  */
 
-#ifndef _BTMRVL_DRV_H_
-#define _BTMRVL_DRV_H_
-
 #include <linux/kthread.h>
 #include <linux/bitops.h>
 #include <net/bluetooth/bluetooth.h>
@@ -142,5 +139,3 @@ int btmrvl_prepare_command(struct btmrvl_private *priv);
 void btmrvl_debugfs_init(struct hci_dev *hdev);
 void btmrvl_debugfs_remove(struct hci_dev *hdev);
 #endif
-
-#endif /* _BTMRVL_DRV_H_ */
diff --git a/drivers/bluetooth/btmrvl_sdio.h b/drivers/bluetooth/btmrvl_sdio.h
index 08bef33..6beb340 100644
--- a/drivers/bluetooth/btmrvl_sdio.h
+++ b/drivers/bluetooth/btmrvl_sdio.h
@@ -19,9 +19,6 @@
  *
  **/
 
-#ifndef _BTMRVL_SDIO_H_
-#define _BTMRVL_SDIO_H_
-
 #define SDIO_HEADER_LEN			4
 
 /* SD block size can not bigger than 64 due to buf size limit in firmware */
@@ -109,5 +106,3 @@ struct btmrvl_sdio_device {
 /* Macros for Data Alignment : address */
 #define ALIGN_ADDR(p, a)	\
 	((((u32)(p)) + (((u32)(a)) - 1)) & ~(((u32)(a)) - 1))
-
-#endif /* _BTMRVL_SDIO_H_ */
-- 
1.6.2.5

