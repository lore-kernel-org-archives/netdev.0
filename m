From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] net/key/af_key.c: make pfkey_table static
Date: Wed, 15 Dec 2004 01:42:54 +0100
Message-ID: <20041215004254.GG23151@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The patch below makes the needlessly global pfkey_table static.


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.10-rc3-mm1-full/net/key/af_key.c.old	2004-12-14 20:22:24.000000000 +0100
+++ linux-2.6.10-rc3-mm1-full/net/key/af_key.c	2004-12-14 20:22:31.000000000 +0100
@@ -35,7 +35,7 @@
 
 
 /* List of all pfkey sockets. */
-HLIST_HEAD(pfkey_table);
+static HLIST_HEAD(pfkey_table);
 static DECLARE_WAIT_QUEUE_HEAD(pfkey_table_wait);
 static rwlock_t pfkey_table_lock = RW_LOCK_UNLOCKED;
 static atomic_t pfkey_table_users = ATOMIC_INIT(0);
