From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 8/7] pppoatm: fix missing wakeup in pppoatm_send()
Date: Fri, 09 Nov 2012 16:30:12 -0500 (EST)
Message-ID: <20121109.163012.719663130136182296.davem@davemloft.net>
References: <1352240222-363-1-git-send-email-krzysiek@podlesie.net>
	<1352292734.7340.35.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krzysiek@podlesie.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, chas@cmf.nrl.navy.mil
To: dwmw2@infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1352292734.7340.35.camel@shinybook.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Woodhouse <dwmw2@infradead.org>
Date: Wed, 07 Nov 2012 12:52:14 +0000

> Now that we can return zero from pppoatm_send() for reasons *other* than
> the queue being full, that means we can't depend on a subsequent call to
> pppoatm_pop() waking the queue, and we might leave it stalled
> indefinitely.
> 
> Fix this by immediately scheduling the wakeup tasklet. As documented
> already elsewhere, the PPP channel's ->downl lock protects against the
> wakeup happening too soon and effectively being missed.
> 
> Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
> ----
> Untested.
> With this sorted, Acked-By: David Woodhouse <David.Woodhouse@intel.com<
> to the other seven. Thanks.

I don't know what to do with this patch because I don't have any
context whatsoever.

So I'm tossing it, please resubmit it when it's meant to be
applied, and with some context.
