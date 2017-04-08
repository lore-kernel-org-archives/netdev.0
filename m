From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 01/22] staging: rtl8723bs: Fix indenting warning in os_dep/xmit_linux.c
Date: Sat,  8 Apr 2017 11:07:24 -0500
Message-ID: <20170408160745.14328-2-Larry.Finger@lwfinger.net>
References: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
        hdegoede@redhat.com, hadess@hadess.net, jes.sorensen@gmail.com,
        Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:33278 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752406AbdDHQID (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 12:08:03 -0400
Received: by mail-oi0-f66.google.com with SMTP id t63so1022460oih.0
        for <netdev@vger.kernel.org>; Sat, 08 Apr 2017 09:08:02 -0700 (PDT)
In-Reply-To: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Smatch issues the warning

  CHECK   drivers/staging/rtl8723bs/os_dep/xmit_linux.c
drivers/staging/rtl8723bs/os_dep/xmit_linux.c:42 _rtw_pktfile_read() warn: inconsistent indenting

A simple indent changes fixes this.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8723bs/os_dep/xmit_linux.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/rtl8723bs/os_dep/xmit_linux.c b/drivers/staging/rtl8723bs/os_dep/xmit_linux.c
index 5ede3b6fbdec..66dfec18f770 100644
--- a/drivers/staging/rtl8723bs/os_dep/xmit_linux.c
+++ b/drivers/staging/rtl8723bs/os_dep/xmit_linux.c
@@ -39,7 +39,7 @@ uint _rtw_pktfile_read (struct pkt_file *pfile, u8 *rmem, uint rlen)
 	len =  rtw_remainder_len(pfile);
 	len = (rlen > len)? len: rlen;
 
-       if (rmem)
+	if (rmem)
 		skb_copy_bits(pfile->pkt, pfile->buf_len-pfile->pkt_len, rmem, len);
 
 	pfile->cur_addr += len;
-- 
2.12.0
