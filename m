From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH 09/15] net: mvneta: use IS_ENABLED() instead of checking for built-in or module
Date: Mon, 12 Sep 2016 16:06:20 +0200
Message-ID: <87poo9dxgj.fsf@free-electrons.com>
References: <1473689026-6983-1-git-send-email-javier@osg.samsung.com>
        <1473689026-6983-10-git-send-email-javier@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        Marcin Wojtas <mw@semihalf.com>,
        "David S. Miller" <davem@davemloft.net>
To: Javier Martinez Canillas <javier@osg.samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473689026-6983-10-git-send-email-javier@osg.samsung.com>
        (Javier Martinez Canillas's message of "Mon, 12 Sep 2016 10:03:40
        -0400")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Javier,
 
 On lun., sept. 12 2016, Javier Martinez Canillas <javier@osg.samsung.com> wrote:

> The IS_ENABLED() macro checks if a Kconfig symbol has been enabled either
> built-in or as a module, use that macro instead of open coding the same.
>
> Using the macro makes the code more readable by helping abstract away some
> of the Kconfig built-in and module enable details.
>
> Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>

Acked-by: Gregory CLEMENT <gregory.clement@free-electrons.com>

Thanks,

Gregory

> ---
>
>  drivers/net/ethernet/marvell/mvneta_bm.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/marvell/mvneta_bm.h b/drivers/net/ethernet/marvell/mvneta_bm.h
> index e74fd44a92f7..a32de432800c 100644
> --- a/drivers/net/ethernet/marvell/mvneta_bm.h
> +++ b/drivers/net/ethernet/marvell/mvneta_bm.h
> @@ -133,7 +133,7 @@ struct mvneta_bm_pool {
>  void *mvneta_frag_alloc(unsigned int frag_size);
>  void mvneta_frag_free(unsigned int frag_size, void *data);
>  
> -#if defined(CONFIG_MVNETA_BM) || defined(CONFIG_MVNETA_BM_MODULE)
> +#if IS_ENABLED(CONFIG_MVNETA_BM)
>  void mvneta_bm_pool_destroy(struct mvneta_bm *priv,
>  			    struct mvneta_bm_pool *bm_pool, u8 port_map);
>  void mvneta_bm_bufs_free(struct mvneta_bm *priv, struct mvneta_bm_pool *bm_pool,
> -- 
> 2.7.4
>

-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
