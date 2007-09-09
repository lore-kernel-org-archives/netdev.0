From: Adrian Bunk <bunk@kernel.org>
Subject: [-mm patch] unexport raise_softirq_irqoff
Date: Sun, 9 Sep 2007 22:25:44 +0200
Message-ID: <20070909202544.GV3563@stusta.de>
References: <20070831215822.26e1432b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>, davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759654AbXIIU32@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070831215822.26e1432b.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 31, 2007 at 09:58:22PM -0700, Andrew Morton wrote:
>...
> Changes since 2.6.23-rc3-mm1:
>...
>  git-net.patch
>...
>  git trees
>...

raise_softirq_irqoff no longer has any modular user.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
eff0407b63757cdd4164a0bdde0313e8f154b6dc 
diff --git a/kernel/softirq.c b/kernel/softirq.c
index abae56c..ce38b56 100644
--- a/kernel/softirq.c
+++ b/kernel/softirq.c
@@ -335,8 +335,6 @@ inline fastcall void raise_softirq_irqoff(unsigned int nr)
 		wakeup_softirqd();
 }
 
-EXPORT_SYMBOL(raise_softirq_irqoff);
-
 void fastcall raise_softirq(unsigned int nr)
 {
 	unsigned long flags;
