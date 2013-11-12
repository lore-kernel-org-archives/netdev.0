From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net/7990: Make lance_private.name const
Date: Wed, 13 Nov 2013 01:04:17 +0300
Message-ID: <5282A5E1.9090501@cogentembedded.com>
References: <1384283649-10482-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-m68k@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <1384283649-10482-1-git-send-email-geert@linux-m68k.org>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 11/12/2013 10:14 PM, Geert Uytterhoeven wrote:

> This allows to drop a few casts.

> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
> ---
>   drivers/net/ethernet/amd/7990.h    |    2 +-
>   drivers/net/ethernet/amd/hplance.c |    2 +-
>   drivers/net/ethernet/amd/mvme147.c |    2 +-
>   3 files changed, 3 insertions(+), 3 deletions(-)

> diff --git a/drivers/net/ethernet/amd/7990.h b/drivers/net/ethernet/amd/7990.h
> index 0a5837b96421..60c60926afda 100644
> --- a/drivers/net/ethernet/amd/7990.h
> +++ b/drivers/net/ethernet/amd/7990.h
> @@ -100,7 +100,7 @@ struct lance_init_block {
>    */
>   struct lance_private
>   {
> -        char *name;
> +        const char *name;

    Indent with tab, not spaces, please.

> diff --git a/drivers/net/ethernet/amd/hplance.c b/drivers/net/ethernet/amd/hplance.c
> index 0c61fd50d882..a9046cf3a564 100644
> --- a/drivers/net/ethernet/amd/hplance.c
> +++ b/drivers/net/ethernet/amd/hplance.c
> @@ -149,7 +149,7 @@ static void hplance_init(struct net_device *dev, struct dio_dev *d)
>           }
>
>           lp = netdev_priv(dev);
> -        lp->lance.name = (char*)d->name;                /* discards const, shut up gcc */
> +        lp->lance.name = d->name;

    Same here.

WBR, Sergei
