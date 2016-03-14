From: Michal Simek <michal.simek@xilinx.com>
Subject: Re: [PATCH 5/5] net: macb: Fix simple typo.
Date: Mon, 14 Mar 2016 21:47:54 +0100
Message-ID: <56E7237A.10401@xilinx.com>
References: <1457896247-25934-1-git-send-email-moritz.fischer@ettus.com>
 <1457896247-25934-6-git-send-email-moritz.fischer@ettus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <michal.simek@xilinx.com>, <joe@perches.com>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <moritz.fischer.private@gmail.com>
To: Moritz Fischer <moritz.fischer@ettus.com>,
	<nicolas.ferre@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457896247-25934-6-git-send-email-moritz.fischer@ettus.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13.3.2016 20:10, Moritz Fischer wrote:
> Signed-off-by: Moritz Fischer <moritz.fischer@ettus.com>
> ---
>  drivers/net/ethernet/cadence/macb.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index a0c01e5..681e5bf 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -127,7 +127,7 @@ static void hw_writel(struct macb *bp, int offset, u32 value)
>  }
>  
>  /* Find the CPU endianness by using the loopback bit of NCR register. When the
> - * CPU is in big endian we need to program swaped mode for management
> + * CPU is in big endian we need to program swapped mode for management
>   * descriptor access.
>   */
>  static bool hw_is_native_io(void __iomem *addr)
> 

Remove dot at the end of subject and feel free to add my:
Acked-by: Michal Simek <michal.simek@xilinx.com>

Thanks,
Michal
