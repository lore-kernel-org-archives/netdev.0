From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH v2 iproute2 2/3] libnamespaces: fix warning about syscall()
Date: Wed, 22 Apr 2015 10:27:06 +0200
Message-ID: <1429691227-12310-2-git-send-email-nicolas.dichtel@6wind.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1CB2312E@AcuExch.aculab.com>
 <1429691227-12310-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com, david.laight@aculab.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:54354 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756149AbbDVI1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 04:27:12 -0400
In-Reply-To: <1429691227-12310-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The warning was:
In file included from namespace.c:14:0:
=2E./include/namespace.h: In function =E2=80=98setns=E2=80=99:
=2E./include/namespace.h:37:2: warning: implicit declaration of functio=
n =E2=80=98syscall=E2=80=99 [-Wimplicit-function-declaration]

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/namespace.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/namespace.h b/include/namespace.h
index a2ac7dccd0e1..5add9d266b7d 100644
--- a/include/namespace.h
+++ b/include/namespace.h
@@ -3,6 +3,7 @@
=20
 #include <sched.h>
 #include <sys/mount.h>
+#include <unistd.h>
 #include <sys/syscall.h>
 #include <errno.h>
=20
--=20
2.2.2
