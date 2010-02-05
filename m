From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 4/6] Bluetooth: Fix memory leak in Marvell BT-over-SDIO driver
Date: Fri,  5 Feb 2010 12:05:37 -0800
Message-ID: <88d1a0cf659438a66135661538ae332b23f8635a.1265399549.git.marcel@holtmann.org>
References: <cover.1265399549.git.marcel@holtmann.org>
 <1038a00b458997661bcd0e780a24dc280a8841fc.1265399549.git.marcel@holtmann.org>
 <485f1eff73a7b932fd3abb0dfcf804e1a1f59025.1265399549.git.marcel@holtmann.org>
 <6c2718da59613d76013b501bf0f8bcf9d7794b2d.1265399549.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:54200 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756914Ab0BEUGq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2010 15:06:46 -0500
In-Reply-To: <6c2718da59613d76013b501bf0f8bcf9d7794b2d.1265399549.git.marcel@holtmann.org>
In-Reply-To: <cover.1265399549.git.marcel@holtmann.org>
References: <cover.1265399549.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yoichi Yuasa <yuasa@linux-mips.org>

Signed-off-by: Yoichi Yuasa <yuasa@linux-mips.org>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 drivers/bluetooth/btmrvl_sdio.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/bluetooth/btmrvl_sdio.c b/drivers/bluetooth/btmrvl_sdio.c
index f36defa..57d965b 100644
--- a/drivers/bluetooth/btmrvl_sdio.c
+++ b/drivers/bluetooth/btmrvl_sdio.c
@@ -808,6 +808,7 @@ static int btmrvl_sdio_host_to_card(struct btmrvl_private *priv,
 
 exit:
 	sdio_release_host(card->func);
+	kfree(tmpbuf);
 
 	return ret;
 }
-- 
1.6.6

