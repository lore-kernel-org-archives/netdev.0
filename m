From: Wei Wang <tracywwnj@gmail.com>
Subject: [PATCH v2 net-next 20/21] net: reorder all the dst flags
Date: Sat, 17 Jun 2017 10:42:43 -0700
Message-ID: <20170617174244.132862-21-tracywwnj@gmail.com>
References: <20170617174244.132862-1-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36255 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752768AbdFQRnu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Jun 2017 13:43:50 -0400
Received: by mail-pf0-f195.google.com with SMTP id y7so11097383pfd.3
        for <netdev@vger.kernel.org>; Sat, 17 Jun 2017 10:43:50 -0700 (PDT)
In-Reply-To: <20170617174244.132862-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

As some dst flags are removed, reorder the dst flags to fill in the
blanks.
Note: these flags are not exposed into user space. So it is safe to
reorder.

Signed-off-by: Wei Wang <weiwan@google.com>
Acked-by: Martin KaFai Lau <kafai@fb.com>
---
 include/net/dst.h | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 642483ed4edf..d912b44d2dcb 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -51,11 +51,11 @@ struct dst_entry {
 #define DST_HOST		0x0001
 #define DST_NOXFRM		0x0002
 #define DST_NOPOLICY		0x0004
-#define DST_NOCOUNT		0x0020
-#define DST_FAKE_RTABLE		0x0040
-#define DST_XFRM_TUNNEL		0x0080
-#define DST_XFRM_QUEUE		0x0100
-#define DST_METADATA		0x0200
+#define DST_NOCOUNT		0x0008
+#define DST_FAKE_RTABLE		0x0010
+#define DST_XFRM_TUNNEL		0x0020
+#define DST_XFRM_QUEUE		0x0040
+#define DST_METADATA		0x0080
 
 	short			error;
 
-- 
2.13.1.518.g3df882009-goog
