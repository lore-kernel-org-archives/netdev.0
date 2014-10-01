From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: dsa: Fix build warning for !PM_SLEEP
Date: Wed, 01 Oct 2014 11:13:54 -0700
Message-ID: <542C4462.8060704@gmail.com>
References: <1412164740-32452-1-git-send-email-thierry.reding@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Thierry Reding <thierry.reding@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412164740-32452-1-git-send-email-thierry.reding@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/01/2014 04:59 AM, Thierry Reding wrote:
> From: Thierry Reding <treding@nvidia.com>
> 
> The dsa_switch_suspend() and dsa_switch_resume() functions are only used
> when PM_SLEEP is enabled, so they need #ifdef CONFIG_PM_SLEEP protection
> to avoid a compiler warning.
> 
> Signed-off-by: Thierry Reding <treding@nvidia.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

Thanks Thierry!

> ---
>  net/dsa/dsa.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
> index 6905f2d84c44..22f34cf4cb27 100644
> --- a/net/dsa/dsa.c
> +++ b/net/dsa/dsa.c
> @@ -238,6 +238,7 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
>  {
>  }
>  
> +#ifdef CONFIG_PM_SLEEP
>  static int dsa_switch_suspend(struct dsa_switch *ds)
>  {
>  	int i, ret = 0;
> @@ -280,6 +281,7 @@ static int dsa_switch_resume(struct dsa_switch *ds)
>  
>  	return 0;
>  }
> +#endif
>  
>  
>  /* link polling *************************************************************/
> 
