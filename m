From: Michal Simek <michal.simek@xilinx.com>
Subject: Re: [PATCH 2/2] net: can: comparison of unsigned variable
Date: Tue, 18 Nov 2014 17:47:02 +0100
Message-ID: <67e24b2a43564b55960a31c62e5d44ca@BY2FFO11FD055.protection.gbl>
References: <1416318427-28676-1-git-send-email-sudipm.mukherjee@gmail.com>
 <1416318427-28676-2-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, linux-can@vger.kernel.org
To: Sudip Mukherjee <sudipm.mukherjee@gmail.com>, Wolfgang Grandegger
 <wg@grandegger.com>, Marc Kleine-Budde <mkl@pengutronix.de>, Michal Simek
 <michal.simek@xilinx.com>, =?windows-1252?Q?S=F6ren_Brinkmann?=
 <soren.brinkmann@xilinx.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1416318427-28676-2-git-send-email-sudipm.mukherjee@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 11/18/2014 02:47 PM, Sudip Mukherjee wrote:
> err was of the type u32. it was being compared with < 0, and being
> an unsigned variable the comparison would have been always false.
> 
> moreover, err was getting the return value from set_reset_mode()
> and xcan_set_bittiming(), and both are returning int.
> 
> Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
> ---
>  drivers/net/can/xilinx_can.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/can/xilinx_can.c b/drivers/net/can/xilinx_can.c
> index 72fe96f..67c2dd4 100644
> --- a/drivers/net/can/xilinx_can.c
> +++ b/drivers/net/can/xilinx_can.c
> @@ -300,7 +300,8 @@ static int xcan_set_bittiming(struct net_device *ndev)
>  static int xcan_chip_start(struct net_device *ndev)
>  {
>  	struct xcan_priv *priv = netdev_priv(ndev);
> -	u32 err, reg_msr, reg_sr_mask;
> +	u32 reg_msr, reg_sr_mask;
> +	int err;
>  	unsigned long timeout;
>  
>  	/* Check if it is in reset mode */
> 

Reviewed-by: Michal Simek <michal.simek@xilinx.com>

Thanks,
Michal
