From: Don Fry <pcnet32@frontier.com>
Subject: Re: [PATCH] amd: Neaten and remove unnecessary OOM messages
Date: Mon, 23 Jun 2014 15:42:11 -0700
Message-ID: <1403563331.12008.5.camel@Lunix2.home>
References: <cover.1403530604.git.joe@perches.com>
	 <c7cdaa8e080157cdabb92278a4c3beba89b49070.1403530604.git.joe@perches.com>
	 <1403546524.12008.2.camel@Lunix2.home>
	 <1403550950.15811.15.camel@joe-AO725> <1403557507.20657.3.camel@joe-AO725>
	 <1403559395.20657.8.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403559395.20657.8.camel@joe-AO725>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-06-23 at 14:36 -0700, Joe Perches wrote:
> Make the code flow a little better for 80 columns.
> 
> Use a consistent style for the RX and TX rings allocation.
> Use BIT macro.
> Use a temporary unsiged int entries for (1<<size).
> Remove the OOM messages as they duplicate the generic
> OOM and dump_stack() provided by the memory subsystem.
> Reflow allocs to 80 columns.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/net/ethernet/amd/pcnet32.c | 43 ++++++++++++++++----------------------
>  1 file changed, 18 insertions(+), 25 deletions(-)
> 
> diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
> index 8099fdc..4a8fdc4 100644
> --- a/drivers/net/ethernet/amd/pcnet32.c
> +++ b/drivers/net/ethernet/amd/pcnet32.c
> @@ -481,36 +481,32 @@ static void pcnet32_realloc_tx_ring(struct net_device *dev,
>  	dma_addr_t *new_dma_addr_list;

Acked-By: Don Fry <pcnet32@frontier.com>

> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
