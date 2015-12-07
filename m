From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH] ethernet: aurora: AURORA_NB8800 should depend on HAS_DMA
Date: Mon, 07 Dec 2015 11:12:21 +0000
Message-ID: <yw1xk2oqo6lm.fsf@unicorn.mansr.com>
References: <1449479346-32601-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449479346-32601-1-git-send-email-geert@linux-m68k.org> (Geert
	Uytterhoeven's message of "Mon, 7 Dec 2015 10:09:06 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Geert Uytterhoeven <geert@linux-m68k.org> writes:

> If NO_DMA=3Dy:
>
>     ERROR: "dma_map_single" [drivers/net/ethernet/aurora/nb8800.ko] u=
ndefined!
>     ERROR: "dma_unmap_page" [drivers/net/ethernet/aurora/nb8800.ko] u=
ndefined!
>     ERROR: "dma_sync_single_for_cpu" [drivers/net/ethernet/aurora/nb8=
800.ko] undefined!
>     ERROR: "dma_unmap_single" [drivers/net/ethernet/aurora/nb8800.ko]=
 undefined!
>     ERROR: "dma_alloc_coherent" [drivers/net/ethernet/aurora/nb8800.k=
o] undefined!
>     ERROR: "dma_mapping_error" [drivers/net/ethernet/aurora/nb8800.ko=
] undefined!
>     ERROR: "dma_map_page" [drivers/net/ethernet/aurora/nb8800.ko] und=
efined!
>     ERROR: "dma_free_coherent" [drivers/net/ethernet/aurora/nb8800.ko=
] undefined!
>
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

Acked-by: Mans Rullgard <mans@mansr.com>

>  drivers/net/ethernet/aurora/Kconfig | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/ethernet/aurora/Kconfig b/drivers/net/ethern=
et/aurora/Kconfig
> index a3c7106fdf85e78f..8ba7f8ff3434000f 100644
> --- a/drivers/net/ethernet/aurora/Kconfig
> +++ b/drivers/net/ethernet/aurora/Kconfig
> @@ -13,6 +13,7 @@ if NET_VENDOR_AURORA
>
>  config AURORA_NB8800
>  	tristate "Aurora AU-NB8800 support"
> +	depends on HAS_DMA
>  	select PHYLIB
>  	help
>  	 Support for the AU-NB8800 gigabit Ethernet controller.
> --=20
> 1.9.1
>

--=20
M=E5ns Rullg=E5rd
mans@mansr.com
