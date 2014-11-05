From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH] include/linux/socket.h: Fix comment
Date: Wed,  5 Nov 2014 21:44:27 +0100
Message-ID: <1415220267-20044-1-git-send-email-linux@rasmusvillemoes.dk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Rasmus Villemoes <linux@rasmusvillemoes.dk>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

File descriptors are always closed on exit :-)

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
 include/linux/socket.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/socket.h b/include/linux/socket.h
index ec538fc..bb9b836 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -256,7 +256,7 @@ struct ucred {
 #define MSG_EOF         MSG_FIN
 
 #define MSG_FASTOPEN	0x20000000	/* Send data in TCP SYN */
-#define MSG_CMSG_CLOEXEC 0x40000000	/* Set close_on_exit for file
+#define MSG_CMSG_CLOEXEC 0x40000000	/* Set close_on_exec for file
 					   descriptor received through
 					   SCM_RIGHTS */
 #if defined(CONFIG_COMPAT)
-- 
2.0.4
