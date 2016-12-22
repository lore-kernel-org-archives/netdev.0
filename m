From: Baruch Siach <baruch@tkos.co.il>
Subject: [PATCH] tc: add missing limits.h header
Date: Thu, 22 Dec 2016 20:52:48 +0200
Message-ID: <c18609c5d906bbba8176138cfafd88c4a38c8190.1482432767.git.baruch@tkos.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Baruch Siach <baruch@tkos.co.il>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from guitar.tcltek.co.il ([192.115.133.116]:54685 "EHLO
        mx.tkos.co.il" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S966655AbcLVSxo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Dec 2016 13:53:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes under musl build issues like:

f_matchall.c: In function ‘matchall_parse_opt’:
f_matchall.c:48:12: error: ‘LONG_MIN’ undeclared (first use in this function)
   if (h == LONG_MIN || h == LONG_MAX) {
            ^
f_matchall.c:48:12: note: each undeclared identifier is reported only once for each function it appears in
f_matchall.c:48:29: error: ‘LONG_MAX’ undeclared (first use in this function)
   if (h == LONG_MIN || h == LONG_MAX) {
                             ^

Signed-off-by: Baruch Siach <baruch@tkos.co.il>
---
 tc/tc_util.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/tc/tc_util.h b/tc/tc_util.h
index f198a4ad5554..4db26c6d5e25 100644
--- a/tc/tc_util.h
+++ b/tc/tc_util.h
@@ -2,6 +2,7 @@
 #define _TC_UTIL_H_ 1
 
 #define MAX_MSG 16384
+#include <limits.h>
 #include <linux/pkt_sched.h>
 #include <linux/pkt_cls.h>
 #include <linux/gen_stats.h>
-- 
2.11.0
