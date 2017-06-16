From: Wei Wang <tracywwnj@gmail.com>
Subject: [PATCH net-next 20/21] net: reorder all the dst flags
Date: Fri, 16 Jun 2017 10:47:43 -0700
Message-ID: <20170616174744.139688-21-tracywwnj@gmail.com>
References: <20170616174744.139688-1-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34591 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752595AbdFPRsi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 13:48:38 -0400
Received: by mail-pg0-f67.google.com with SMTP id j186so7271369pge.1
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 10:48:38 -0700 (PDT)
In-Reply-To: <20170616174744.139688-1-tracywwnj@gmail.com>
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
