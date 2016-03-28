From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sxgbe: fix error paths in sxgbe_platform_probe()
Date: Sun, 27 Mar 2016 22:40:51 -0400 (EDT)
Message-ID: <20160327.224051.626731642699154866.davem@davemloft.net>
References: <877fgue1mx.fsf@rasmusvillemoes.dk>
	<1459027449-2667-1-git-send-email-linux@rasmusvillemoes.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux@rasmusvillemoes.dk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459027449-2667-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Date: Sat, 26 Mar 2016 22:24:09 +0100

> We need to use post-decrement to ensure that irq_dispose_mapping is
> also called on priv->rxq[0]->irq_no; moreover, if one of the above for
> loops failed already at i==0 (so we reach one of these labels with
> that value of i), we'll enter an essentially infinite loop of
> out-of-bounds accesses.
> 
> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>

Applied, thanks.

> David, can you take this directly? Of the three samsung people listed
> by get_maintainer.pl, one address bounces and another informed me
> privately that he's not actually a maintainer of this anymore.

That's awesome, another pump and dump driver submission.
