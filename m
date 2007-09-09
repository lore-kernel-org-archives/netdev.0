From: Adrian Bunk <bunk@kernel.org>
Subject: [-mm patch] really unexport do_softirq
Date: Sun, 9 Sep 2007 22:25:40 +0200
Message-ID: <20070909202540.GU3563@stusta.de>
References: <20070831215822.26e1432b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	Robert Olsson <robert.olsson@its.uu.se>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760023AbXIIU2w@vger.kernel.org>
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

This hydra had more than one head...

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 arch/i386/kernel/irq.c    |    2 --
 arch/powerpc/kernel/irq.c |    1 -
 arch/s390/kernel/irq.c    |    1 -
 arch/sh/kernel/irq.c      |    1 -
 arch/x86_64/kernel/irq.c  |    1 -
 5 files changed, 6 deletions(-)

68791fe88172ac3c2dbb0fbbffb8befc7b59e3f7 
diff --git a/arch/i386/kernel/irq.c b/arch/i386/kernel/irq.c
index a6b2c7e..de1601f 100644
--- a/arch/i386/kernel/irq.c
+++ b/arch/i386/kernel/irq.c
@@ -231,8 +231,6 @@ asmlinkage void do_softirq(void)
 
 	local_irq_restore(flags);
 }
-
-EXPORT_SYMBOL(do_softirq);
 #endif
 
 /*
diff --git a/arch/powerpc/kernel/irq.c b/arch/powerpc/kernel/irq.c
index dfad0e4..65c2409 100644
--- a/arch/powerpc/kernel/irq.c
+++ b/arch/powerpc/kernel/irq.c
@@ -395,7 +395,6 @@ void do_softirq(void)
 
 	local_irq_restore(flags);
 }
-EXPORT_SYMBOL(do_softirq);
 
 
 /*
diff --git a/arch/s390/kernel/irq.c b/arch/s390/kernel/irq.c
index 8f0cbca..c36d812 100644
--- a/arch/s390/kernel/irq.c
+++ b/arch/s390/kernel/irq.c
@@ -95,7 +95,6 @@ asmlinkage void do_softirq(void)
 
 	local_irq_restore(flags);
 }
-EXPORT_SYMBOL(do_softirq);
 
 void init_irq_proc(void)
 {
diff --git a/arch/sh/kernel/irq.c b/arch/sh/kernel/irq.c
index 0340498..4b49d03 100644
--- a/arch/sh/kernel/irq.c
+++ b/arch/sh/kernel/irq.c
@@ -245,7 +245,6 @@ asmlinkage void do_softirq(void)
 
 	local_irq_restore(flags);
 }
-EXPORT_SYMBOL(do_softirq);
 #endif
 
 void __init init_IRQ(void)
diff --git a/arch/x86_64/kernel/irq.c b/arch/x86_64/kernel/irq.c
index 87423b7..3542f0c 100644
--- a/arch/x86_64/kernel/irq.c
+++ b/arch/x86_64/kernel/irq.c
@@ -236,4 +236,3 @@ asmlinkage void do_softirq(void)
 	}
  	local_irq_restore(flags);
 }
-EXPORT_SYMBOL(do_softirq);
