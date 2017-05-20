From: Khem Raj <raj.khem@gmail.com>
Subject: [PATCH] include stdint.h explicitly for UINT16_MAX)
Date: Sat, 20 May 2017 14:28:46 -0700
Message-ID: <20170520212846.3534-1-raj.khem@gmail.com>
Cc: Khem Raj <raj.khem@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33904 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753217AbdETV24 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 20 May 2017 17:28:56 -0400
Received: by mail-pf0-f194.google.com with SMTP id w69so13154480pfk.1
        for <netdev@vger.kernel.org>; Sat, 20 May 2017 14:28:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes
| tc_core.c:190:29: error: 'UINT16_MAX' undeclared (first use in this function); did you mean '__INT16_MAX__'?
|    if ((sz >> s->size_log) > UINT16_MAX) {
|                              ^~~~~~~~~~

Signed-off-by: Khem Raj <raj.khem@gmail.com>
---
 tc/tc_core.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/tc/tc_core.c b/tc/tc_core.c
index 7bbe0d7..821b741 100644
--- a/tc/tc_core.c
+++ b/tc/tc_core.c
@@ -12,6 +12,7 @@
 
 #include <stdio.h>
 #include <stdlib.h>
+#include <stdint.h>
 #include <unistd.h>
 #include <syslog.h>
 #include <fcntl.h>
-- 
2.13.0
