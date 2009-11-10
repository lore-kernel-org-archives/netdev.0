From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [PATCH] Documentation: rw_lock lessons learned
Date: Tue, 10 Nov 2009 13:23:49 -0500
Message-ID: <4AF9AFB5.7080809@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020008060903090007010701"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:40616 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757511AbZKJSXu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 13:23:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020008060903090007010701
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

In recent weeks, two different network projects erroneously
strayed down the rw_lock path.  Update the Documentation
based upon comments in those threads.
---
  Documentation/spinlocks.txt |   14 ++++++++++++++
  1 files changed, 14 insertions(+), 0 deletions(-)

--------------020008060903090007010701
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="spinlocks.txt.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="spinlocks.txt.patch"

diff --git a/Documentation/spinlocks.txt b/Documentation/spinlocks.txt
index 619699d..c112052 100644
--- a/Documentation/spinlocks.txt
+++ b/Documentation/spinlocks.txt
@@ -233,4 +233,18 @@ indeed), while write-locks need to protect themselves against interrupts.
 
 		Linus
 
+----
+
+The implications of spin_locks on memory are further described in:
+
+  Documentation/memory-barriers.txt
+    (5) LOCK operations.
+    (6) UNLOCK operations.
+
+----
+
+We are working hard to remove reader-writer spinlocks (rw_lock) from the
+network stack, so please don't add a new one.  Instead, see:
+
+  Documentation/RCU/rcu.txt
 
-- 
1.6.3.3


--------------020008060903090007010701--
