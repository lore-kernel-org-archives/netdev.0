From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] gianfar: correct the bad expression while writing bit-pattern
Date: Mon, 12 Jan 2015 17:12:11 +0300
Message-ID: <54B3D63B.1010608@cogentembedded.com>
References: <1421048596-22639-1-git-send-email-sanjeev_sharma@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: claudiu.manoil@freescale.com, peter.senna@gmail.com,
	shemminger@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sanjeev Sharma <sanjeev_sharma@mentor.com>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421048596-22639-1-git-send-email-sanjeev_sharma@mentor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 1/12/2015 10:43 AM, Sanjeev Sharma wrote:

> This patch correct the bad expression while writing the
> bit-pattern from software's buffer to hardware registers.

> Signed-off-by: Sanjeev Sharma <Sanjeev_Sharma@mentor.com>
> ---
>   drivers/net/ethernet/freescale/gianfar_ethtool.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)

> diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
> index 3e1a9c1..1ccca72 100644
> --- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
> +++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
> @@ -1586,7 +1586,7 @@ static int gfar_write_filer_table(struct gfar_private *priv,
>   		return -EBUSY;
>
>   	/* Fill regular entries */
> -	for (; i < MAX_FILER_IDX - 1 && (tab->fe[i].ctrl | tab->fe[i].ctrl);
> +	for (; i < MAX_FILER_IDX - 1 && ( i < tab->fe[i].ctrl);

    Inner parens not needed. And there shouldn't be space after (.

WBR, Sergei
