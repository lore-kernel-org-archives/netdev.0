From: Jiri Slaby <jirislaby@gmail.com>
Subject: [PATCH 1/5] Net: ibm_newemac, remove SPIN_LOCK_UNLOCKED
Date: Fri, 9 Nov 2007 18:31:26 -0500
Message-ID: <4827138842526222333@pripojeni.net>
Cc: <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760378AbXKIXbg@vger.kernel.org>
Cc: Jeff Garzik <jgarzik@pobox.com>
Cc: <netdev@vger.kernel.org>
Cc: <bryan.wu@analog.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ibm_newemac, remove SPIN_LOCK_UNLOCKED

SPIN_LOCK_UNLOCKED is deprecated, use DEFINE_SPINLOCK instead

Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
Cc: Jeff Garzik <jgarzik@pobox.com>

---
commit aefcf0f6b6ab925184e7cebff8b609e4da1f5c0d
tree 9e1e6240f26c759826959e8812885726c520019d
parent f87566db6dd9613dde8de59380cd2f423166511e
author Jiri Slaby <jirislaby@gmail.com> Thu, 25 Oct 2007 11:54:41 +0200
committer Jiri Slaby <jirislaby@gmail.com> Thu, 25 Oct 2007 11:54:41 +0200

 drivers/net/ibm_newemac/debug.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ibm_newemac/debug.c b/drivers/net/ibm_newemac/debug.c
index 170524e..ada13cd 100644
--- a/drivers/net/ibm_newemac/debug.c
+++ b/drivers/net/ibm_newemac/debug.c
@@ -21,7 +21,7 @@
 
 #include "core.h"
 
-static spinlock_t emac_dbg_lock = SPIN_LOCK_UNLOCKED;
+static DEFINE_SPINLOCK(emac_dbg_lock);
 
 static void emac_desc_dump(struct emac_instance *p)
 {
