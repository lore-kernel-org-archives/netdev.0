From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 11/22] staging: rtl8723bs: Fix indenting problems in core/rtw_xmit.c
Date: Sat,  8 Apr 2017 11:07:34 -0500
Message-ID: <20170408160745.14328-12-Larry.Finger@lwfinger.net>
References: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
        hdegoede@redhat.com, hadess@hadess.net, jes.sorensen@gmail.com,
        Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:36138 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752577AbdDHQIL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 12:08:11 -0400
Received: by mail-oi0-f67.google.com with SMTP id b187so16472635oif.3
        for <netdev@vger.kernel.org>; Sat, 08 Apr 2017 09:08:11 -0700 (PDT)
In-Reply-To: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Smatch logs the following:

  CHECK   drivers/staging/rtl8723bs/core/rtw_xmit.c
drivers/staging/rtl8723bs/core/rtw_xmit.c:277 _rtw_init_xmit_priv() warn: inconsistent indenting
drivers/staging/rtl8723bs/core/rtw_xmit.c:294 _rtw_free_xmit_priv() warn: inconsistent indenting
drivers/staging/rtl8723bs/core/rtw_xmit.c:295 _rtw_free_xmit_priv() warn: inconsistent indenting
drivers/staging/rtl8723bs/core/rtw_xmit.c:946 xmitframe_addmic() warn: inconsistent indenting

These are fixed with white-space changes.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8723bs/core/rtw_xmit.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/rtl8723bs/core/rtw_xmit.c b/drivers/staging/rtl8723bs/core/rtw_xmit.c
index 60585540069a..8f2c9a6658bf 100644
--- a/drivers/staging/rtl8723bs/core/rtw_xmit.c
+++ b/drivers/staging/rtl8723bs/core/rtw_xmit.c
@@ -274,7 +274,7 @@ s32	_rtw_init_xmit_priv(struct xmit_priv *pxmitpriv, struct adapter *padapter)
 	rtw_alloc_hwxmits(padapter);
 	rtw_init_hwxmits(pxmitpriv->hwxmits, pxmitpriv->hwxmit_entry);
 
-  for (i = 0; i < 4; i++) {
+	for (i = 0; i < 4; i++) {
 		pxmitpriv->wmm_para_seq[i] = i;
 	}
 
@@ -290,8 +290,8 @@ s32	_rtw_init_xmit_priv(struct xmit_priv *pxmitpriv, struct adapter *padapter)
 
 void _rtw_free_xmit_priv(struct xmit_priv *pxmitpriv)
 {
-       int i;
-      struct adapter *padapter = pxmitpriv->adapter;
+	int i;
+	struct adapter *padapter = pxmitpriv->adapter;
 	struct xmit_frame	*pxmitframe = (struct xmit_frame *) pxmitpriv->pxmit_frame_buf;
 	struct xmit_buf *pxmitbuf = (struct xmit_buf *)pxmitpriv->pxmitbuf;
 
@@ -942,8 +942,8 @@ static s32 xmitframe_addmic(struct adapter *padapter, struct xmit_frame *pxmitfr
 
 			}
 
-      /* if (pqospriv->qos_option == 1) */
-      if (pattrib->qos_en)
+			/* if (pqospriv->qos_option == 1) */
+			if (pattrib->qos_en)
 				priority[0] = (u8)pxmitframe->attrib.priority;
 
 
-- 
2.12.0
