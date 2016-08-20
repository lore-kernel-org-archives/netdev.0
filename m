From: Gustavo Zacarias <gustavo@zacarias.com.ar>
Subject: [PATCH iproute2] ss: fix build with musl libc
Date: Sat, 20 Aug 2016 00:11:10 -0300
Message-ID: <1471662670-20969-1-git-send-email-gustavo@zacarias.com.ar>
Cc: Gustavo Zacarias <gustavo@zacarias.com.ar>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.zacarias.com.ar ([176.9.42.171]:38792 "EHLO
        www.zacarias.com.ar" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750838AbcHTDVx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 23:21:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

UINT_MAX usage requires limits.h, so include it.

Signed-off-by: Gustavo Zacarias <gustavo@zacarias.com.ar>
---
 misc/ss.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/misc/ss.c b/misc/ss.c
index e758f57..3b268d9 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -26,6 +26,7 @@
 #include <fnmatch.h>
 #include <getopt.h>
 #include <stdbool.h>
+#include <limits.h>
 
 #include "utils.h"
 #include "rt_names.h"
-- 
2.7.3
