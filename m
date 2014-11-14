From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] reciprocal_div: objects with exported symbols should be obj-y rather than lib-y
Date: Fri, 14 Nov 2014 15:16:47 +0100
Message-ID: <85de478df37362b703cb5db64cbfc48d4d4439f5.1415974584.git.hannes@stressinduktion.org>
Cc: jim.epost@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:43678 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754655AbaKNOQx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 09:16:53 -0500
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 2110A20CE9
	for <netdev@vger.kernel.org>; Fri, 14 Nov 2014 09:16:53 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Otherwise the exported symbols might be discarded because of no users
in vmlinux.

Reported-by: Jim Davis <jim.epost@gmail.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 lib/Makefile | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/Makefile b/lib/Makefile
index 04e53dd..4b9baa4 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -10,7 +10,7 @@ endif
 lib-y := ctype.o string.o vsprintf.o cmdline.o \
 	 rbtree.o radix-tree.o dump_stack.o timerqueue.o\
 	 idr.o int_sqrt.o extable.o \
-	 sha1.o md5.o irq_regs.o reciprocal_div.o argv_split.o \
+	 sha1.o md5.o irq_regs.o argv_split.o \
 	 proportions.o flex_proportions.o ratelimit.o show_mem.o \
 	 is_single_threaded.o plist.o decompress.o kobject_uevent.o \
 	 earlycpio.o
@@ -26,7 +26,7 @@ obj-y += bcd.o div64.o sort.o parser.o halfmd4.o debug_locks.o random32.o \
 	 bust_spinlocks.o hexdump.o kasprintf.o bitmap.o scatterlist.o \
 	 gcd.o lcm.o list_sort.o uuid.o flex_array.o iovec.o clz_ctz.o \
 	 bsearch.o find_last_bit.o find_next_bit.o llist.o memweight.o kfifo.o \
-	 percpu-refcount.o percpu_ida.o rhashtable.o
+	 percpu-refcount.o percpu_ida.o rhashtable.o reciprocal_div.o
 obj-y += string_helpers.o
 obj-$(CONFIG_TEST_STRING_HELPERS) += test-string_helpers.o
 obj-y += kstrtox.o
-- 
1.9.3
