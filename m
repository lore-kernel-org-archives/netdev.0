From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Subject: [PATCH net-next 1/2] New getsockopt option to get socket cookie
Date: Wed,  5 Apr 2017 19:00:55 -0700
Message-ID: <1491444056-4312-2-git-send-email-chenbofeng.kernel@gmail.com>
References: <1491444056-4312-1-git-send-email-chenbofeng.kernel@gmail.com>
Cc: Lorenzo Colitti <lorenzo@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Chenbo Feng <fengc@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:32796 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756281AbdDFCBK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 22:01:10 -0400
Received: by mail-io0-f195.google.com with SMTP id f84so3067694ioj.0
        for <netdev@vger.kernel.org>; Wed, 05 Apr 2017 19:01:10 -0700 (PDT)
In-Reply-To: <1491444056-4312-1-git-send-email-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chenbo Feng <fengc@google.com>

Introduce a new getsockopt operation to retrieve the socket cookie
for a specific socket based on the socket fd.  It returns a unique
non-decreasing cookie for each socket.
Tested: https://android-review.googlesource.com/#/c/358163/

Acked-by: Willem de Bruijn <willemb@google.com>
Signed-off-by: Chenbo Feng <fengc@google.com>
---
 arch/alpha/include/uapi/asm/socket.h   | 2 ++
 arch/avr32/include/uapi/asm/socket.h   | 2 ++
 arch/frv/include/uapi/asm/socket.h     | 2 ++
 arch/ia64/include/uapi/asm/socket.h    | 2 ++
 arch/m32r/include/uapi/asm/socket.h    | 2 ++
 arch/mips/include/uapi/asm/socket.h    | 2 ++
 arch/mn10300/include/uapi/asm/socket.h | 2 ++
 arch/parisc/include/uapi/asm/socket.h  | 2 ++
 arch/powerpc/include/uapi/asm/socket.h | 2 ++
 arch/s390/include/uapi/asm/socket.h    | 2 ++
 arch/sparc/include/uapi/asm/socket.h   | 2 ++
 arch/xtensa/include/uapi/asm/socket.h  | 2 ++
 include/uapi/asm-generic/socket.h      | 2 ++
 net/core/sock.c                        | 8 ++++++++
 14 files changed, 34 insertions(+)

diff --git a/arch/alpha/include/uapi/asm/socket.h b/arch/alpha/include/uapi/asm/socket.h
index 1bb8cac..148d7a3 100644
--- a/arch/alpha/include/uapi/asm/socket.h
+++ b/arch/alpha/include/uapi/asm/socket.h
@@ -103,4 +103,6 @@
 
 #define SO_INCOMING_NAPI_ID	56
 
+#define SO_COOKIE		57
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/avr32/include/uapi/asm/socket.h b/arch/avr32/include/uapi/asm/socket.h
index f824eeb..2434d08 100644
--- a/arch/avr32/include/uapi/asm/socket.h
+++ b/arch/avr32/include/uapi/asm/socket.h
@@ -96,4 +96,6 @@
 
 #define SO_INCOMING_NAPI_ID	56
 
+#define SO_COOKIE		57
+
 #endif /* _UAPI__ASM_AVR32_SOCKET_H */
diff --git a/arch/frv/include/uapi/asm/socket.h b/arch/frv/include/uapi/asm/socket.h
index a8ad9be..1ccf456 100644
--- a/arch/frv/include/uapi/asm/socket.h
+++ b/arch/frv/include/uapi/asm/socket.h
@@ -96,5 +96,7 @@
 
 #define SO_INCOMING_NAPI_ID	56
 
+#define SO_COOKIE		57
+
 #endif /* _ASM_SOCKET_H */
 
diff --git a/arch/ia64/include/uapi/asm/socket.h b/arch/ia64/include/uapi/asm/socket.h
index 6af3253..2c3f4b4 100644
--- a/arch/ia64/include/uapi/asm/socket.h
+++ b/arch/ia64/include/uapi/asm/socket.h
@@ -105,4 +105,6 @@
 
 #define SO_INCOMING_NAPI_ID	56
 
+#define SO_COOKIE		57
+
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/arch/m32r/include/uapi/asm/socket.h b/arch/m32r/include/uapi/asm/socket.h
index e98b6bb..ae6548d 100644
--- a/arch/m32r/include/uapi/asm/socket.h
+++ b/arch/m32r/include/uapi/asm/socket.h
@@ -96,4 +96,6 @@
 
 #define SO_INCOMING_NAPI_ID	56
 
+#define SO_COOKIE		57
+
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/arch/mips/include/uapi/asm/socket.h b/arch/mips/include/uapi/asm/socket.h
index ae2b62e..3418ec9 100644
--- a/arch/mips/include/uapi/asm/socket.h
+++ b/arch/mips/include/uapi/asm/socket.h
@@ -114,4 +114,6 @@
 
 #define SO_INCOMING_NAPI_ID	56
 
+#define SO_COOKIE		57
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/mn10300/include/uapi/asm/socket.h b/arch/mn10300/include/uapi/asm/socket.h
index e4ac184..4526e92 100644
--- a/arch/mn10300/include/uapi/asm/socket.h
+++ b/arch/mn10300/include/uapi/asm/socket.h
@@ -96,4 +96,6 @@
 
 #define SO_INCOMING_NAPI_ID	56
 
+#define SO_COOKIE		57
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/parisc/include/uapi/asm/socket.h b/arch/parisc/include/uapi/asm/socket.h
index f754c79..5147018 100644
--- a/arch/parisc/include/uapi/asm/socket.h
+++ b/arch/parisc/include/uapi/asm/socket.h
@@ -95,4 +95,6 @@
 
 #define SO_INCOMING_NAPI_ID	0x4031
 
+#define SO_COOKIE		0x4032
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/powerpc/include/uapi/asm/socket.h b/arch/powerpc/include/uapi/asm/socket.h
index 5f84af7..58e2ec0 100644
--- a/arch/powerpc/include/uapi/asm/socket.h
+++ b/arch/powerpc/include/uapi/asm/socket.h
@@ -103,4 +103,6 @@
 
 #define SO_INCOMING_NAPI_ID	56
 
+#define SO_COOKIE		57
+
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff --git a/arch/s390/include/uapi/asm/socket.h b/arch/s390/include/uapi/asm/socket.h
index 25ac496..e8e5ecf 100644
--- a/arch/s390/include/uapi/asm/socket.h
+++ b/arch/s390/include/uapi/asm/socket.h
@@ -102,4 +102,6 @@
 
 #define SO_INCOMING_NAPI_ID	56
 
+#define SO_COOKIE		57
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/sparc/include/uapi/asm/socket.h b/arch/sparc/include/uapi/asm/socket.h
index b05513a..3f4ad19 100644
--- a/arch/sparc/include/uapi/asm/socket.h
+++ b/arch/sparc/include/uapi/asm/socket.h
@@ -92,6 +92,8 @@
 
 #define SO_INCOMING_NAPI_ID	0x003a
 
+#define SO_COOKIE		0x003b
+
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
 #define SO_SECURITY_ENCRYPTION_TRANSPORT	0x5002
diff --git a/arch/xtensa/include/uapi/asm/socket.h b/arch/xtensa/include/uapi/asm/socket.h
index 786606c..1eb6d2f 100644
--- a/arch/xtensa/include/uapi/asm/socket.h
+++ b/arch/xtensa/include/uapi/asm/socket.h
@@ -107,4 +107,6 @@
 
 #define SO_INCOMING_NAPI_ID	56
 
+#define SO_COOKIE		57
+
 #endif	/* _XTENSA_SOCKET_H */
diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
index c98a52f..2b48856 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -98,4 +98,6 @@
 
 #define SO_INCOMING_NAPI_ID	56
 
+#define SO_COOKIE		57
+
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/net/core/sock.c b/net/core/sock.c
index 392f9b6..a06bb7a 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1083,6 +1083,7 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 
 	union {
 		int val;
+		u64 val64;
 		struct linger ling;
 		struct timeval tm;
 	} v;
@@ -1340,6 +1341,13 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		break;
 #endif
 
+	case SO_COOKIE:
+		lv = sizeof(u64);
+		if (len < lv)
+			return -EINVAL;
+		v.val64 = sock_gen_cookie(sk);
+		break;
+
 	default:
 		/* We implement the SO_SNDLOWAT etc to not be settable
 		 * (1003.1g 7).
-- 
2.7.4
