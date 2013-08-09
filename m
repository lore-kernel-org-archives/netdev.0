From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net:ethernet:korina.c Removed IRQF_DISABLED
Date: Fri, 09 Aug 2013 09:28:06 -0700
Message-ID: <1376065686.2087.102.camel@joe-AO722>
References: <1375989649-7252-1-git-send-email-kumargauravgupta3@gmail.com>
	 <20130808210918.GE5502@mwanda>
	 <20130808.142054.1541424422807503741.davem@davemloft.net>
	 <1375997625.2087.14.camel@joe-AO722> <520452F4.2070804@gmail.com>
	 <1376015984.2087.31.camel@joe-AO722> <520457AD.9060508@gmail.com>
	 <1376016864.2087.34.camel@joe-AO722> <52045B31.9000002@gmail.com>
	 <1376018881.2087.48.camel@joe-AO722> <5204641C.3090905@gmail.com>
	 <CA+MoWDrsHf4NFE_iszymh6SaBfXsMybC194ZQaKgURmCFwiJRQ@mail.gmail.com>
	 <1376061267.2087.91.camel@joe-AO722>
	 <CA+MoWDqsDWSD_q93UyiPNFzmgXGGfCPMH9VeQf1YmiO6OYuhwQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Kumar Gaurav <kumargauravgupta3@gmail.com>,
	David Miller <davem@davemloft.net>,
	Dan Carpenter <dan.carpenter@oracle.com>, emilio@elopez.com.ar,
	mugunthanvnm@ti.com, jg1.han@samsung.com,
	hsweeten@visionengravers.com, netdev <netdev@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Peter Senna Tschudin <peter.senna@gmail.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <CA+MoWDqsDWSD_q93UyiPNFzmgXGGfCPMH9VeQf1YmiO6OYuhwQ@mail.gmail.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-08-09 at 17:53 +0200, Peter Senna Tschudin wrote:
> On Fri, Aug 9, 2013 at 5:14 PM, Joe Perches <joe@perches.com> wrote:
> > On Fri, 2013-08-09 at 15:15 +0200, Peter Senna Tschudin wrote:
> >> Coccinelle (http://coccinelle.lip6.fr/) can help you in this task.
[]
> Peter's useful conversion won't find/convert cases where
> > IRQF_DISABLED is used in a #define like:
> >> diff --git a/drivers/net/ethernet/micrel/ks8851_mll.c b/drivers/net/ethernet/micrel/ks8851_mll.c
> >> []
> >> @@ -915,7 +915,7 @@ static int ks_net_open(struct net_device *netdev)
> >> []
> >> -#define        KS_INT_FLAGS    (IRQF_DISABLED|IRQF_TRIGGER_LOW)
> >> +#define        KS_INT_FLAGS    (IRQF_TRIGGER_LOW)

Hi again.

> Coccinelle works with macros,

Sometimes yes.  Perfectly?  No.

> the problem in this specific case [...]

Other problems exist.
#include processing is troublesome.

> But, I would prefer to remove this define instead of patching it,
> seems to make more sense to me.

That'd be OK with me too.

Anyway, the point was not that coccinelle is bad.

Cocinelle's output, just like output from sed or
any other automated tool, still needs thoughtful
investigation and review.

(did I mention Coccinelle's a way cool tool?)

cheers, Joe

