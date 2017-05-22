From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next] net: define PKTINFO timestamping option in all archs
Date: Sun, 21 May 2017 23:31:47 -0400
Message-ID: <20170522033147.17264-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, mlichvar@redhat.com,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:33895 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756695AbdEVDbw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 May 2017 23:31:52 -0400
Received: by mail-qk0-f196.google.com with SMTP id u75so17416741qka.1
        for <netdev@vger.kernel.org>; Sun, 21 May 2017 20:31:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

The newly introduced timestamping option SCM_TIMESTAMPING_PKTINFO
is defined in asm-generic/socket.h. Also define it in the architecture
specific versions.

Fixes: aad9c8c470f2 ("net: add new control message for incoming HW-timestamped packets")
Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
CC: Miroslav Lichvar <mlichvar@redhat.com>
Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 arch/alpha/include/uapi/asm/socket.h   | 2 ++
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
 11 files changed, 22 insertions(+)

diff --git a/arch/alpha/include/uapi/asm/socket.h b/arch/alpha/include/uapi/asm/socket.h
index 148d7a32754e..0926de63a62b 100644
--- a/arch/alpha/include/uapi/asm/socket.h
+++ b/arch/alpha/include/uapi/asm/socket.h
@@ -105,4 +105,6 @@
 
 #define SO_COOKIE		57
 
+#define SCM_TIMESTAMPING_PKTINFO	58
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/frv/include/uapi/asm/socket.h b/arch/frv/include/uapi/asm/socket.h
index 1ccf45657472..e491ff08b9a9 100644
--- a/arch/frv/include/uapi/asm/socket.h
+++ b/arch/frv/include/uapi/asm/socket.h
@@ -98,5 +98,7 @@
 
 #define SO_COOKIE		57
 
+#define SCM_TIMESTAMPING_PKTINFO	58
+
 #endif /* _ASM_SOCKET_H */
 
diff --git a/arch/ia64/include/uapi/asm/socket.h b/arch/ia64/include/uapi/asm/socket.h
index 2c3f4b48042a..869372413333 100644
--- a/arch/ia64/include/uapi/asm/socket.h
+++ b/arch/ia64/include/uapi/asm/socket.h
@@ -107,4 +107,6 @@
 
 #define SO_COOKIE		57
 
+#define SCM_TIMESTAMPING_PKTINFO	58
+
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/arch/m32r/include/uapi/asm/socket.h b/arch/m32r/include/uapi/asm/socket.h
index ae6548d29a18..5d97890a8704 100644
--- a/arch/m32r/include/uapi/asm/socket.h
+++ b/arch/m32r/include/uapi/asm/socket.h
@@ -98,4 +98,6 @@
 
 #define SO_COOKIE		57
 
+#define SCM_TIMESTAMPING_PKTINFO	58
+
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/arch/mips/include/uapi/asm/socket.h b/arch/mips/include/uapi/asm/socket.h
index 3418ec9c1c50..365ff51f033a 100644
--- a/arch/mips/include/uapi/asm/socket.h
+++ b/arch/mips/include/uapi/asm/socket.h
@@ -116,4 +116,6 @@
 
 #define SO_COOKIE		57
 
+#define SCM_TIMESTAMPING_PKTINFO	58
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/mn10300/include/uapi/asm/socket.h b/arch/mn10300/include/uapi/asm/socket.h
index 4526e92301a6..d013c0da0256 100644
--- a/arch/mn10300/include/uapi/asm/socket.h
+++ b/arch/mn10300/include/uapi/asm/socket.h
@@ -98,4 +98,6 @@
 
 #define SO_COOKIE		57
 
+#define SCM_TIMESTAMPING_PKTINFO	58
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/parisc/include/uapi/asm/socket.h b/arch/parisc/include/uapi/asm/socket.h
index 514701840bd9..b893ca14fade 100644
--- a/arch/parisc/include/uapi/asm/socket.h
+++ b/arch/parisc/include/uapi/asm/socket.h
@@ -97,4 +97,6 @@
 
 #define SO_COOKIE		0x4032
 
+#define SCM_TIMESTAMPING_PKTINFO	0x4033
+
 #endif /* _UAPI_ASM_SOCKET_H */
diff --git a/arch/powerpc/include/uapi/asm/socket.h b/arch/powerpc/include/uapi/asm/socket.h
index 58e2ec0310fc..bc4ca72faf99 100644
--- a/arch/powerpc/include/uapi/asm/socket.h
+++ b/arch/powerpc/include/uapi/asm/socket.h
@@ -105,4 +105,6 @@
 
 #define SO_COOKIE		57
 
+#define SCM_TIMESTAMPING_PKTINFO	58
+
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff --git a/arch/s390/include/uapi/asm/socket.h b/arch/s390/include/uapi/asm/socket.h
index e8e5ecf673fd..fb9769d7e74e 100644
--- a/arch/s390/include/uapi/asm/socket.h
+++ b/arch/s390/include/uapi/asm/socket.h
@@ -104,4 +104,6 @@
 
 #define SO_COOKIE		57
 
+#define SCM_TIMESTAMPING_PKTINFO	58
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/sparc/include/uapi/asm/socket.h b/arch/sparc/include/uapi/asm/socket.h
index 3f4ad19d9ec7..5d673302fd41 100644
--- a/arch/sparc/include/uapi/asm/socket.h
+++ b/arch/sparc/include/uapi/asm/socket.h
@@ -94,6 +94,8 @@
 
 #define SO_COOKIE		0x003b
 
+#define SCM_TIMESTAMPING_PKTINFO	0x003c
+
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
 #define SO_SECURITY_ENCRYPTION_TRANSPORT	0x5002
diff --git a/arch/xtensa/include/uapi/asm/socket.h b/arch/xtensa/include/uapi/asm/socket.h
index 1eb6d2fe70d3..982c2533f912 100644
--- a/arch/xtensa/include/uapi/asm/socket.h
+++ b/arch/xtensa/include/uapi/asm/socket.h
@@ -109,4 +109,6 @@
 
 #define SO_COOKIE		57
 
+#define SCM_TIMESTAMPING_PKTINFO	58
+
 #endif	/* _XTENSA_SOCKET_H */
-- 
2.13.0.303.g4ebf302169-goog
