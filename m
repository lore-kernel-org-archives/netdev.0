From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2 1/2] lib: fix warning in namespace.h
Date: Thu, 15 Jan 2015 11:36:24 +0100
Message-ID: <1421318185-10858-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Vadim Kochan <vadim4j@gmail.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:48904 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751901AbbAOKgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 05:36:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Warning was:
In file included from bridge.c:16:0:
=2E./include/namespace.h:33:12: warning: =E2=80=98setns=E2=80=99 define=
d but not used [-Wunused-function]

CC: Vadim Kochan <vadim4j@gmail.com>
=46ixes: eb67e4498aec ("lib: Add netns_switch func for change network n=
amespace")
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/namespace.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/namespace.h b/include/namespace.h
index b8c5cad6aaa2..28a4223b3eb2 100644
--- a/include/namespace.h
+++ b/include/namespace.h
@@ -30,7 +30,7 @@
 #endif
=20
 #ifndef HAVE_SETNS
-static int setns(int fd, int nstype)
+static inline int setns(int fd, int nstype)
 {
 #ifdef __NR_setns
 	return syscall(__NR_setns, fd, nstype);
--=20
2.1.0
