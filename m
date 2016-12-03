From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next] tcp: fix the missing avr32 SOF_TIMESTAMPING_OPT_STATS
Date: Sat,  3 Dec 2016 14:46:22 -0800
Message-ID: <1480805182-7150-1-git-send-email-ycheng@google.com>
Cc: paul.gortmaker@windriver.com, netdev@vger.kernel.org,
        Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:33856 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751317AbcLCWqo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 17:46:44 -0500
Received: by mail-pf0-f174.google.com with SMTP id c4so57692658pfb.1
        for <netdev@vger.kernel.org>; Sat, 03 Dec 2016 14:46:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit of SOF_TIMESTAMPING_OPT_STATS didn't include the
new header for avr32, causing build to break. The patch fixes it.

Fixes: 1c885808e456 ("tcp: SOF_TIMESTAMPING_OPT_STATS option for SO_TIMESTAMPING")
Reported-by: Paul Gortmaker <paul.gortmaker@windriver.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 arch/avr32/include/uapi/asm/socket.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/avr32/include/uapi/asm/socket.h b/arch/avr32/include/uapi/asm/socket.h
index 1fd147f..5a65042 100644
--- a/arch/avr32/include/uapi/asm/socket.h
+++ b/arch/avr32/include/uapi/asm/socket.h
@@ -90,4 +90,6 @@
 
 #define SO_CNX_ADVICE		53
 
+#define SCM_TIMESTAMPING_OPT_STATS	54
+
 #endif /* _UAPI__ASM_AVR32_SOCKET_H */
-- 
2.8.0.rc3.226.g39d4020
