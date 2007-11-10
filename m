From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 3/13] tg3: APE flag fix
Date: Fri, 09 Nov 2007 16:38:43 -0800
Message-ID: <1194655123.5745.265.camel@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1628 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751925AbXKJAjI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Nov 2007 19:39:08 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch corrects a bug where the ENABLE_APE flag was tested against
the wrong flag variable.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 82b1cf0..833cb9b 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -10881,7 +10881,7 @@ static void __devinit tg3_read_fw_ver(struct tg3 *tp)
 	}
 
 	if (!(tp->tg3_flags & TG3_FLAG_ENABLE_ASF) ||
-	     (tp->tg3_flags & TG3_FLG3_ENABLE_APE))
+	     (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE))
 		return;
 
 	for (offset = TG3_NVM_DIR_START;


