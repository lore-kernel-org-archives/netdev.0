From: Michal Simek <michal.simek@xilinx.com>
Subject: Re: [PATCH 09/16 linux-next] net: xilinx: constify of_device_id array
Date: Wed, 18 Mar 2015 07:50:10 +0100
Message-ID: <BY2FFO11FD004365A4A4A7796DC551DCFE2000@BY2FFO11FD004.protection.gbl>
References: <1426617469-781-1-git-send-email-fabf@skynet.be>
 <1426617469-781-10-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <davem@davemloft.net>, Michal Simek <michal.simek@xilinx.com>,
	=?windows-1252?Q?S=F6ren_Brinkmann?= <soren.brinkmann@xilinx.com>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	John Linn <John.Linn@xilinx.com>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Fabian Frederick <fabf@skynet.be>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426617469-781-10-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/17/2015 07:37 PM, Fabian Frederick wrote:
> of_device_id is always used as const.
> (See driver.of_match_table and open firmware functions)
> 
> Signed-off-by: Fabian Frederick <fabf@skynet.be>
> ---
>  drivers/net/ethernet/xilinx/ll_temac_main.c       | 2 +-
>  drivers/net/ethernet/xilinx/xilinx_axienet_main.c | 2 +-
>  drivers/net/ethernet/xilinx/xilinx_emaclite.c     | 2 +-
>  3 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
> index dbcbf0c..690a4c3 100644
> --- a/drivers/net/ethernet/xilinx/ll_temac_main.c
> +++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
> @@ -1157,7 +1157,7 @@ static int temac_of_remove(struct platform_device *op)
>  	return 0;
>  }
>  
> -static struct of_device_id temac_of_match[] = {
> +static const struct of_device_id temac_of_match[] = {
>  	{ .compatible = "xlnx,xps-ll-temac-1.01.b", },
>  	{ .compatible = "xlnx,xps-ll-temac-2.00.a", },
>  	{ .compatible = "xlnx,xps-ll-temac-2.02.a", },
> diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
> index a6d2860..28b7e7d 100644
> --- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
> +++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
> @@ -48,7 +48,7 @@
>  #define AXIENET_REGS_N		32
>  
>  /* Match table for of_platform binding */
> -static struct of_device_id axienet_of_match[] = {
> +static const struct of_device_id axienet_of_match[] = {
>  	{ .compatible = "xlnx,axi-ethernet-1.00.a", },
>  	{ .compatible = "xlnx,axi-ethernet-1.01.a", },
>  	{ .compatible = "xlnx,axi-ethernet-2.01.a", },
> diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
> index 9d4ce38..2111b91 100644
> --- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
> +++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
> @@ -1231,7 +1231,7 @@ static struct net_device_ops xemaclite_netdev_ops = {
>  };
>  
>  /* Match table for OF platform binding */
> -static struct of_device_id xemaclite_of_match[] = {
> +static const struct of_device_id xemaclite_of_match[] = {
>  	{ .compatible = "xlnx,opb-ethernetlite-1.01.a", },
>  	{ .compatible = "xlnx,opb-ethernetlite-1.01.b", },
>  	{ .compatible = "xlnx,xps-ethernetlite-1.00.a", },
> 

Acked-by: Michal Simek <michal.simek@xilinx.com>

Thanks,
Michal
