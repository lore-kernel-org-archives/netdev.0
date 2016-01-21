From: Gustavo Zacarias <gustavo@zacarias.com.ar>
Subject: [PATCH] iproute2: fix building with musl
Date: Thu, 21 Jan 2016 15:19:48 -0300
Message-ID: <1453400388-3107-1-git-send-email-gustavo@zacarias.com.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gustavo Zacarias <gustavo@zacarias.com.ar>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.zacarias.com.ar ([176.9.42.171]:59574 "EHLO
	www.zacarias.com.ar" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759611AbcAUSZO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2016 13:25:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need limits.h for PATH_MAX, fixes:

rt_names.c:364:13: error: =E2=80=98PATH_MAX=E2=80=99 undeclared (first =
use in this
function)

Signed-off-by: Gustavo Zacarias <gustavo@zacarias.com.ar>
---
 lib/rt_names.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/lib/rt_names.c b/lib/rt_names.c
index f6d17c0..b665d3e 100644
--- a/lib/rt_names.c
+++ b/lib/rt_names.c
@@ -18,6 +18,7 @@
 #include <sys/time.h>
 #include <sys/socket.h>
 #include <dirent.h>
+#include <limits.h>
=20
 #include <asm/types.h>
 #include <linux/rtnetlink.h>
--=20
2.4.10
