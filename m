From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 8/9 RESENT] staging: r8188eu: Fix sparse warnings in rtw_xmit.c
Date: Fri, 18 Oct 2013 16:37:44 -0500
Message-ID: <5261AA28.9080904@lwfinger.net>
References: <1382129563-8496-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	"org devel"@driverdev.osuosl.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:55982 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754406Ab3JRVhq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 17:37:46 -0400
Received: by mail-ob0-f176.google.com with SMTP id uy5so1716849obc.35
        for <netdev@vger.kernel.org>; Fri, 18 Oct 2013 14:37:45 -0700 (PDT)
In-Reply-To: <1382129563-8496-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sparse displays the following:

   CHECK   drivers/staging/rtl8188eu/core/rtw_xmit.c
drivers/staging/rtl8188eu/core/rtw_xmit.c:830:23: warning: incorrect type in 
initializer (different base types)
drivers/staging/rtl8188eu/core/rtw_xmit.c:830:23:    expected unsigned short 
[usertype] *fctrl
drivers/staging/rtl8188eu/core/rtw_xmit.c:830:23:    got restricted __le16 
*<noident>

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
  drivers/staging/rtl8188eu/core/rtw_xmit.c | 2 +-
  1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_xmit.c 
b/drivers/staging/rtl8188eu/core/rtw_xmit.c
index a594e51..0110816 100644
--- a/drivers/staging/rtl8188eu/core/rtw_xmit.c
+++ b/drivers/staging/rtl8188eu/core/rtw_xmit.c
@@ -827,7 +827,7 @@ s32 rtw_make_wlanhdr (struct adapter *padapter , u8 *hdr, 
struct pkt_attrib *pat
  	u8 qos_option = false;
   	int res = _SUCCESS;
-	u16 *fctrl = &pwlanhdr->frame_ctl;
+	__le16 *fctrl = &pwlanhdr->frame_ctl;
   	struct sta_info *psta;
  -- 1.8.4
