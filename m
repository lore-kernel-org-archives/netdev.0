From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 02/13] staging: r8188eu: Remove pointless "alignment" entry in recv_frame
Date: Fri, 14 Feb 2014 16:54:06 -0600
Message-ID: <1392418457-3203-3-git-send-email-Larry.Finger@lwfinger.net>
References: <1392418457-3203-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Jes.Sorensen@redhat.com
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f42.google.com ([209.85.219.42]:39654 "EHLO
	mail-oa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752910AbaBNWyj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 17:54:39 -0500
Received: by mail-oa0-f42.google.com with SMTP id i7so15375833oag.1
        for <netdev@vger.kernel.org>; Fri, 14 Feb 2014 14:54:39 -0800 (PST)
In-Reply-To: <1392418457-3203-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This alignment entry in union recv_frame does nothing. It certainly
dues not ensure alignment.

Suggested-by: Jes.Sorensen@redhat.com
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Jes.Sorensen@redhat.com
---
 drivers/staging/rtl8188eu/include/rtw_recv.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/staging/rtl8188eu/include/rtw_recv.h b/drivers/staging/rtl8188eu/include/rtw_recv.h
index 866c9e4..c6d7a65 100644
--- a/drivers/staging/rtl8188eu/include/rtw_recv.h
+++ b/drivers/staging/rtl8188eu/include/rtw_recv.h
@@ -292,7 +292,6 @@ struct recv_frame_hdr {
 union recv_frame {
 	union {
 		struct recv_frame_hdr hdr;
-		uint mem[RECVFRAME_HDR_ALIGN>>2];
 	} u;
 };
 
-- 
1.8.4.5
