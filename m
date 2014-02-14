From: Mike Galbraith <bitbucket@online.de>
Subject: [patch] net,bonding: fix bond_options.c direct rwlock.h include
Date: Fri, 14 Feb 2014 08:21:04 +0100
Message-ID: <1392362464.5579.41.camel@marge.simpson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


drivers/net/bonding/bond_options.c includes rwlock.h directly,
which is a nono, and which also breaks RT kernel build.

Signed-off-by: Mike Galbraith <bitbucket@online.de>
---
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 11cb943222d5..c37878432717 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -14,7 +14,7 @@
 #include <linux/errno.h>
 #include <linux/if.h>
 #include <linux/netdevice.h>
-#include <linux/rwlock.h>
+#include <linux/spinlock.h>
 #include <linux/rcupdate.h>
 #include <linux/ctype.h>
 #include <linux/inet.h>
