From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] b44.c Use dev_kfree_skb_irq() in b44_tx()
Date: Wed, 23 Nov 2011 16:40:44 -0500 (EST)
Message-ID: <20111123.164044.1368395311869170507.davem@davemloft.net>
References: <Re:_softirq_oops_from_b44_poll>
	<1322056588-26171-1-git-send-email-LKML@hover.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peter.p.waskiewicz.jr@intel.com, zambrano@broadcom.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: LKML@hover.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1322056588-26171-1-git-send-email-LKML@hover.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xander Hover <LKML@hover.be>
Date: Wed, 23 Nov 2011 14:56:28 +0100

> Reported issues when using dev_kfree_skb() on UP systems and
> systems with low numbers of cores.  dev_kfree_skb_irq() will
> properly save IRQ state before freeing the skb.
> 
> Tested on 3.1.1 and 3.2_rc2
 ...
> Signed-off-by: Xander Hover <LKML@hover.be>

Applied, thanks.
