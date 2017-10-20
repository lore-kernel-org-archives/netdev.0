From: Randy Dunlap <rdunlap@infradead.org>
Subject: [PATCH] textsearch: fix typos in library helpers
Date: Fri, 20 Oct 2017 12:15:52 -0700
Message-ID: <8d229510-1022-b6fd-f95a-085dbc545c0a@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:47885 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751028AbdJTTPz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 15:15:55 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <rdunlap@infradead.org>

Fix spellos (typos) in textsearch library helpers.

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
---
 lib/ts_fsm.c |    2 +-
 lib/ts_kmp.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

--- lnx-414-rc5.orig/lib/ts_fsm.c
+++ lnx-414-rc5/lib/ts_fsm.c
@@ -11,7 +11,7 @@
  * ==========================================================================
  *
  *   A finite state machine consists of n states (struct ts_fsm_token)
- *   representing the pattern as a finite automation. The data is read
+ *   representing the pattern as a finite automaton. The data is read
  *   sequentially on an octet basis. Every state token specifies the number
  *   of recurrences and the type of value accepted which can be either a
  *   specific character or ctype based set of characters. The available
--- lnx-414-rc5.orig/lib/ts_kmp.c
+++ lnx-414-rc5/lib/ts_kmp.c
@@ -27,7 +27,7 @@
  *
  *   [1] Cormen, Leiserson, Rivest, Stein
  *       Introdcution to Algorithms, 2nd Edition, MIT Press
- *   [2] See finite automation theory
+ *   [2] See finite automaton theory
  */
 
 #include <linux/module.h>
