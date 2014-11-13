From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] sh_eth: r8a779x: Enable automatically fetch receive descriptor
Date: Fri, 14 Nov 2014 00:57:39 +0300
Message-ID: <54652953.9030300@cogentembedded.com>
References: <1415861819-27812-1-git-send-email-ykaneko0929@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>, linux-sh@vger.kernel.org,
	Grant Likely <grant.likely@linaro.org>
To: Yoshihiro Kaneko <ykaneko0929@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1415861819-27812-1-git-send-email-ykaneko0929@gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 11/13/2014 09:56 AM, Yoshihiro Kaneko wrote:

> From: Kouei Abe <kouei.abe.cp@renesas.com>

> HDMAC automatically fetches the receive descriptor and receives frames.
> Continuous reception of multiple frames is possible.

> Signed-off-by: Kouei Abe <kouei.abe.cp@renesas.com>
> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
> ---

> This patch is based on net-next tree.

    This patch is not needed any more because of an earlier patch by Ben Dooks 
that set RMCR.RNC for all Ether devices.

>   drivers/net/ethernet/renesas/sh_eth.c | 1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index dbe8606..badb734 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> @@ -494,6 +494,7 @@ static struct sh_eth_cpu_data r8a779x_data = {
>   	.eesr_err_check	= EESR_TWB | EESR_TABT | EESR_RABT | EESR_RFE |
>   			  EESR_RDE | EESR_RFRMER | EESR_TFE | EESR_TDE |
>   			  EESR_ECI,
> +	.rmcr_value	= RMCR_RNC,

    Looks like you didn't even bother to compile.

WBR, Sergei

