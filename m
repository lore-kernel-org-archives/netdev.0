From: <jie.yang@atheros.com>
Subject: [PATCH net-next]atl1c: fix spelling error
Date: Mon, 1 Jun 2009 10:07:58 +0800
Message-ID: <12438220782521-git-send-email-jie.yang@atheros.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <pyunyh@gmail.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, Jie Yang <jie.yang@atheros.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.atheros.com ([12.36.123.2]:18389 "EHLO mail.atheros.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753924AbZFACKB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 May 2009 22:10:01 -0400
Received: from mail.atheros.com ([10.10.20.105])
	by sidewinder.atheros.com
	for <netdev@vger.kernel.org>; Sun, 31 May 2009 19:10:04 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix spelling error

Signed-off-by: Jie Yang <jie.yang@atheros.com>
---
diff --git a/drivers/net/atl1c/atl1c_main.c b/drivers/net/atl1c/atl1c_main.c
index 598c294..8475ff4 100644
--- a/drivers/net/atl1c/atl1c_main.c
+++ b/drivers/net/atl1c/atl1c_main.c
@@ -1115,7 +1115,7 @@ static int atl1c_stop_mac(struct atl1c_hw *hw)
 
 	AT_READ_REG(hw, REG_TXQ_CTRL, &data);
 	data &= ~TXQ_CTRL_EN;
-	AT_WRITE_REG(hw, REG_TWSI_CTRL, data);
+	AT_WRITE_REG(hw, REG_TXQ_CTRL, data);
 
 	for (timeout = 0; timeout < AT_HW_MAX_IDLE_DELAY; timeout++) {
 		AT_READ_REG(hw, REG_IDLE_STATUS, &data);
