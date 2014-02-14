From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 08/13] staging: r8188eu: Remove unused union
Date: Fri, 14 Feb 2014 16:54:12 -0600
Message-ID: <1392418457-3203-9-git-send-email-Larry.Finger@lwfinger.net>
References: <1392418457-3203-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f49.google.com ([209.85.219.49]:45323 "EHLO
	mail-oa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753013AbaBNWyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 17:54:54 -0500
Received: by mail-oa0-f49.google.com with SMTP id i7so15057206oag.8
        for <netdev@vger.kernel.org>; Fri, 14 Feb 2014 14:54:54 -0800 (PST)
In-Reply-To: <1392418457-3203-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/include/rtw_xmit.h | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/drivers/staging/rtl8188eu/include/rtw_xmit.h b/drivers/staging/rtl8188eu/include/rtw_xmit.h
index 1ac1dd3..62f5db1 100644
--- a/drivers/staging/rtl8188eu/include/rtw_xmit.h
+++ b/drivers/staging/rtl8188eu/include/rtw_xmit.h
@@ -105,11 +105,6 @@ struct tx_desc {
 	__le32 txdw7;
 };
 
-union txdesc {
-	struct tx_desc txdesc;
-	unsigned int value[TXDESC_SIZE>>2];
-};
-
 struct	hw_xmit	{
 	struct __queue *sta_queue;
 	int	accnt;
-- 
1.8.4.5
