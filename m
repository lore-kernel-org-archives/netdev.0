From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 05/13] staging: r8188eu: Remove unused get_rxbuf_desc()
Date: Fri, 14 Feb 2014 16:54:09 -0600
Message-ID: <1392418457-3203-6-git-send-email-Larry.Finger@lwfinger.net>
References: <1392418457-3203-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Jes Sorensen <Jes.Sorensen@redhat.com>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:42333 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752913AbaBNWys (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 17:54:48 -0500
Received: by mail-ob0-f171.google.com with SMTP id wp4so14671573obc.2
        for <netdev@vger.kernel.org>; Fri, 14 Feb 2014 14:54:47 -0800 (PST)
In-Reply-To: <1392418457-3203-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported-by: Jes Sorensen <Jes.Sorensen@redhat.com>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Jes Sorensen <Jes.Sorensen@redhat.com>
---
 drivers/staging/rtl8188eu/include/rtw_recv.h | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/drivers/staging/rtl8188eu/include/rtw_recv.h b/drivers/staging/rtl8188eu/include/rtw_recv.h
index 81fdcf5..2159639 100644
--- a/drivers/staging/rtl8188eu/include/rtw_recv.h
+++ b/drivers/staging/rtl8188eu/include/rtw_recv.h
@@ -406,15 +406,6 @@ static inline u8 *recvframe_pull_tail(struct recv_frame *precvframe, int sz)
 	return precvframe->rx_tail;
 }
 
-static inline unsigned char *get_rxbuf_desc(struct recv_frame *precvframe)
-{
-	unsigned char *buf_desc;
-
-	if (precvframe == NULL)
-		return NULL;
-	return buf_desc;
-}
-
 static inline int get_recvframe_len(struct recv_frame *precvframe)
 {
 	return precvframe->len;
-- 
1.8.4.5
