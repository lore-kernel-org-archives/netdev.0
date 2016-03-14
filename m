From: Michal Simek <michal.simek@xilinx.com>
Subject: Re: [PATCH 2/5] net: macb: Fix coding style warnings
Date: Mon, 14 Mar 2016 21:53:15 +0100
Message-ID: <56E724BB.5030600@xilinx.com>
References: <1457896247-25934-1-git-send-email-moritz.fischer@ettus.com>
 <1457896247-25934-3-git-send-email-moritz.fischer@ettus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <michal.simek@xilinx.com>, <joe@perches.com>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <moritz.fischer.private@gmail.com>
To: Moritz Fischer <moritz.fischer@ettus.com>,
	<nicolas.ferre@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457896247-25934-3-git-send-email-moritz.fischer@ettus.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13.3.2016 20:10, Moritz Fischer wrote:
> This commit takes care of the coding style warnings
> that are mostly due to a different comment style and
> lines over 80 chars, as well as a dangling else.
> 
> Signed-off-by: Moritz Fischer <moritz.fischer@ettus.com>
> ---
>  drivers/net/ethernet/cadence/macb.c | 101 +++++++++++++++---------------------
>  1 file changed, 43 insertions(+), 58 deletions(-)
> 
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index 4370f37..c2d31c5 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -58,8 +58,7 @@
>  
>  #define GEM_MTU_MIN_SIZE	68
>  
> -/*
> - * Graceful stop timeouts in us. We should allow up to
> +/* Graceful stop timeouts in us. We should allow up to
>   * 1 frame time (10 Mbits/s, full-duplex, ignoring collisions)
>   */
>  #define MACB_HALT_TIMEOUT	1230
> @@ -127,8 +126,7 @@ static void hw_writel(struct macb *bp, int offset, u32 value)
>  	writel_relaxed(value, bp->regs + offset);
>  }
>  
> -/*
> - * Find the CPU endianness by using the loopback bit of NCR register. When the
> +/* Find the CPU endianness by using the loopback bit of NCR register. When the

TBH: I would rather see this converting to kernel-doc format instead of
using this networking block.

Also splitting this to more patches will be better. Just by categories
but that's just my opinion.

Thanks,
Michal
