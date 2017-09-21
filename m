From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next] test_rhashtable: remove initdata annotation
Date: Thu, 21 Sep 2017 17:36:08 +0200
Message-ID: <20170921153608.8789-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:38622 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751709AbdIUPft (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 11:35:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

kbuild test robot reported a section mismatch warning w. gcc 4.x:
WARNING: lib/test_rhashtable.o(.text+0x139e):
Section mismatch in reference from the function rhltable_insert.clone.3() to the variable .init.data:rhlt

so remove this annotation.

Fixes: cdd4de372ea06 ("test_rhashtable: add test case for rhl_table interface")
Reported-by: kbuild test robot <lkp@intel.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
I don't see this warning with same .config and gcc 6.3.x; however
the annotation isn't essential so just remove it.

diff --git a/lib/test_rhashtable.c b/lib/test_rhashtable.c
index de4d0584631a..8e83cbdc049c 100644
--- a/lib/test_rhashtable.c
+++ b/lib/test_rhashtable.c
@@ -251,7 +251,7 @@ static s64 __init test_rhashtable(struct rhashtable *ht, struct test_obj *array,
 }
 
 static struct rhashtable ht;
-static struct rhltable rhlt __initdata;
+static struct rhltable rhlt;
 
 static int __init test_rhltable(unsigned int entries)
 {
-- 
2.13.5
