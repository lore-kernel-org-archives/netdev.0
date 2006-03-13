From: Adrian Bunk <bunk@stusta.de>
Subject: [-mm patch] make drivers/net/tg3.c:tg3_request_irq()
Date: Mon, 13 Mar 2006 22:26:02 +0100
Message-ID: <20060313212602.GL13973@stusta.de>
References: <20060312031036.3a382581.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751310AbWCMV0F@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>, davem@davemloft.net
Content-Disposition: inline
In-Reply-To: <20060312031036.3a382581.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 12, 2006 at 03:10:36AM -0800, Andrew Morton wrote:
>...
> Changes since 2.6.16-rc5-mm3:
>...
>  git-net.patch
>...
>  git trees
>...


This patch makes the needlessly global function tg3_request_irq() 
static.


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.16-rc6-mm1-full/drivers/net/tg3.c.old	2006-03-13 21:13:31.000000000 +0100
+++ linux-2.6.16-rc6-mm1-full/drivers/net/tg3.c	2006-03-13 21:14:26.000000000 +0100
@@ -6531,7 +6531,7 @@
 	add_timer(&tp->timer);
 }
 
-int tg3_request_irq(struct tg3 *tp)
+static int tg3_request_irq(struct tg3 *tp)
 {
 	irqreturn_t (*fn)(int, void *, struct pt_regs *);
 	unsigned long flags;
