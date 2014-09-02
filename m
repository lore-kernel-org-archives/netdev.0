From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH] net: calxedaxgmac: fix driver dependencies
Date: Mon, 1 Sep 2014 21:36:39 -0500
Message-ID: <CAL_JsqJV0rJ_PCLBsZNYdYdbER7UR_MV40BGjpykh7uubLh__g@mail.gmail.com>
References: <7268934.nBXHizFkl4@amdc1032>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Kyungmin Park <kyungmin.park@samsung.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7268934.nBXHizFkl4@amdc1032>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 1, 2014 at 10:39 AM, Bartlomiej Zolnierkiewicz
<b.zolnierkie@samsung.com> wrote:
> Calxeda 1G/10G XGMAC Ethernet support should be available only on
> Calxeda ECX-1000/2000 (Highbank/Midway) platforms.
>
> Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Acked-by: Kyungmin Park <kyungmin.park@samsung.com>
> Cc: Rob Herring <robh@kernel.org>
> ---
>  drivers/net/ethernet/calxeda/Kconfig |    1 +
>  1 file changed, 1 insertion(+)
>
> Index: b/drivers/net/ethernet/calxeda/Kconfig
> ===================================================================
> --- a/drivers/net/ethernet/calxeda/Kconfig      2014-07-30 14:31:12.159522474 +0200
> +++ b/drivers/net/ethernet/calxeda/Kconfig      2014-09-01 17:33:49.232810483 +0200
> @@ -1,6 +1,7 @@
>  config NET_CALXEDA_XGMAC
>         tristate "Calxeda 1G/10G XGMAC Ethernet driver"
>         depends on HAS_IOMEM && HAS_DMA
> +       depends on ARCH_HIGHBANK || COMPILE_TEST

Opinions differ on whether drivers should be restricted in this way.
There is no actual dependency requiring ARCH_HIGHBANK. So I leave it
to David.

Rob
