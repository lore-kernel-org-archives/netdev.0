From: Gregory Haskins <ghaskins@novell.com>
Subject: [-next PATCH 1/4] vbus: make library code properly declared as GPL
Date: Mon, 23 Nov 2009 14:54:34 -0500
Message-ID: <20091123195434.8184.70297.stgit@dev.haskins.net>
References: <20091123195136.8184.68042.stgit@dev.haskins.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net
To: linux-next@vger.kernel.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20091123195136.8184.68042.stgit@dev.haskins.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This facilitates building the shm-signal and ioq libraries as kernel
modules.

Signed-off-by: Gregory Haskins <ghaskins@novell.com>
---

 lib/ioq.c        |    4 ++++
 lib/shm_signal.c |    4 ++++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/lib/ioq.c b/lib/ioq.c
index a6c8664..d5e57be 100644
--- a/lib/ioq.c
+++ b/lib/ioq.c
@@ -25,6 +25,10 @@
 #include <linux/bitops.h>
 #include <linux/module.h>
 
+MODULE_AUTHOR("Gregory Haskins");
+MODULE_LICENSE("GPL");
+MODULE_VERSION("1");
+
 #ifndef NULL
 #define NULL 0
 #endif
diff --git a/lib/shm_signal.c b/lib/shm_signal.c
index fbba74f..8d3e9b4 100644
--- a/lib/shm_signal.c
+++ b/lib/shm_signal.c
@@ -24,6 +24,10 @@
 #include <linux/interrupt.h>
 #include <linux/shm_signal.h>
 
+MODULE_AUTHOR("Gregory Haskins");
+MODULE_LICENSE("GPL");
+MODULE_VERSION("1");
+
 int shm_signal_enable(struct shm_signal *s, int flags)
 {
 	struct shm_signal_irq *irq = &s->desc->irq[s->locale];
