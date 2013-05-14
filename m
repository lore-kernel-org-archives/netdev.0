From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RFC PATCH net-next v2 2/3] sh_eth: add support RMIIMODE register
Date: Tue, 14 May 2013 17:48:55 +0400
Message-ID: <519240C7.1060406@cogentembedded.com>
References: <1368499073-21975-1-git-send-email-horms+renesas@verge.net.au> <1368499073-21975-3-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	Magnus Damm <magnus.damm@gmail.com>
To: Simon Horman <horms+renesas@verge.net.au>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1368499073-21975-3-git-send-email-horms+renesas@verge.net.au>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 14-05-2013 6:37, Simon Horman wrote:

> This change is motivated by the lager board which uses the r8a7790 SoC,
> an R-Car SoC. For this board setting the RMIIMODE register is necessary.

> This patch assumes this is valid for all R-Car SoCs.

    No, RMIIMODE register is not documented on R8A7778/9 SoCs and this 
location is described as reserved. How's it called in R8A7790 manual, CXR15?

> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

> --

    Missed a dash here.

> v2
> * Split from patch to add r8a7790 support to driver (ifdef nastiness)
> * As suggested by Sergei Shtylyov
>    - Add a field to struct sh_eth_cpu_data to indicate if the
>      rmiimode register is present. This replaces an extremely ugly ifdef.
> ---
>   drivers/net/ethernet/renesas/sh_eth.c | 5 +++++
>   drivers/net/ethernet/renesas/sh_eth.h | 2 ++
>   2 files changed, 7 insertions(+)

> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index 016cf80..ff5613d 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> @@ -190,6 +190,7 @@ static const u16 sh_eth_offset_fast_rcar[SH_ETH_MAX_REGISTER_OFFSET] = {
>   	[RMCR]		= 0x0258,
>   	[TFUCR]		= 0x0264,
>   	[RFOCR]		= 0x0268,
> +	[RMIIMODE]      = 0x026c,
>   	[FCFTR]		= 0x0270,
>   	[TRIMD]		= 0x027c,
>   };

WBR, Sergei

