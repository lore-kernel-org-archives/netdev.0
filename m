From: Alexander Shiyan <shc_work@mail.ru>
Subject: [PATCH] irda: sir_dev: Fix copy/paste typo
Date: Tue, 20 Nov 2012 23:59:11 +0400
Message-ID: <1353441551-4359-1-git-send-email-shc_work@mail.ru>
Cc: Samuel Ortiz <samuel@sortiz.org>,
	Alexander Shiyan <shc_work@mail.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback4.mail.ru ([94.100.176.42]:46042 "EHLO
	fallback4.mail.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751859Ab2KTUgj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2012 15:36:39 -0500
Received: from smtp36.i.mail.ru (smtp36.i.mail.ru [94.100.177.96])
	by fallback4.mail.ru (mPOP.Fallback_MX) with ESMTP id 1C115145425
	for <netdev@vger.kernel.org>; Tue, 20 Nov 2012 23:59:36 +0400 (MSK)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Alexander Shiyan <shc_work@mail.ru>
---
 drivers/net/irda/sir_dev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/irda/sir_dev.c b/drivers/net/irda/sir_dev.c
index 5039f08..43e9ab4 100644
--- a/drivers/net/irda/sir_dev.c
+++ b/drivers/net/irda/sir_dev.c
@@ -222,7 +222,7 @@ static void sirdev_config_fsm(struct work_struct *work)
 			break;
 
 		case SIRDEV_STATE_DONGLE_SPEED:
-			if (dev->dongle_drv->reset) {
+			if (dev->dongle_drv->set_speed) {
 				ret = dev->dongle_drv->set_speed(dev, fsm->param);
 				if (ret < 0) {
 					fsm->result = ret;
-- 
1.7.8.6
