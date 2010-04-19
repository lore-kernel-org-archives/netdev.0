From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: tip: origin tree build failure, [patch] fix isdn/gigaset build
 failure
Date: Mon, 19 Apr 2010 11:14:55 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.1004191112550.14500@i5.linux-foundation.org>
References: <20100419.003857.260094283.davem@davemloft.net> <20100419172731.GA4358@elte.hu> <20100419.103304.35342954.davem@davemloft.net> <20100419180520.GA9244@elte.hu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, tilman@imap.cc,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100419180520.GA9244@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Mon, 19 Apr 2010, Ingo Molnar wrote:
> 
> Note, i just found that my patch is not enough as we fail the build elsewhere as well:

Maybe add the #include <linux/sched.h> into gigaset.h, instead of 
common.c?

IOW..

		Linus
---
 drivers/isdn/gigaset/gigaset.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/isdn/gigaset/gigaset.h b/drivers/isdn/gigaset/gigaset.h
index d32efb6..05947f9 100644
--- a/drivers/isdn/gigaset/gigaset.h
+++ b/drivers/isdn/gigaset/gigaset.h
@@ -20,6 +20,7 @@
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
 #include <linux/kernel.h>
+#include <linux/sched.h>
 #include <linux/compiler.h>
 #include <linux/types.h>
 #include <linux/ctype.h>
