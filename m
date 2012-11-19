From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/macb: move to circ_buf macros and fix initial
 condition
Date: Mon, 19 Nov 2012 14:22:41 -0500 (EST)
Message-ID: <20121119.142241.1136499358405707363.davem@davemloft.net>
References: <1353338244-11506-1-git-send-email-nicolas.ferre@atmel.com>
	<1353340821-12658-1-git-send-email-nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, plagnioj@jcrosoft.com, manabian@gmail.com,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: nicolas.ferre@atmel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1353340821-12658-1-git-send-email-nicolas.ferre@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicolas Ferre <nicolas.ferre@atmel.com>
Date: Mon, 19 Nov 2012 17:00:21 +0100

> Move to circular buffers management macro and correct an error
> with circular buffer initial condition.
> 
> Without this patch, the macb_tx_ring_avail() function was
> not reporting the proper ring availability at startup:
> macb macb: eth0: BUG! Tx Ring full when queue awake!
> macb macb: eth0: tx_head = 0, tx_tail = 0
> And hanginig forever...
> 
> I remove the macb_tx_ring_avail() function and use the
> proven macros from circ_buf.h. CIRC_CNT() is used in the
> "consumer" part of the driver: macb_tx_interrupt() to match
> advice from Documentation/circular-buffers.txt.
> 
> Reported-by: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
> Tested-by: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>

Applied, thanks.

> ---
> v2: - added tags from Jean-Christophe PLAGNIOL-VILLARD

Note that under normal circumstances, if the only change is the
tags that people added in replies, you don't need to do this.

Patchwork accumulates all of the signoffs, acks, tested-by,
reviewed-by, etc. tags made in replies to the patch automatically for
me, so when I apply the patch they will be there.
