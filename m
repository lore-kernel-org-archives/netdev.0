From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 2/5][v2] phylib: introduce PHY_INTERFACE_MODE_XGMII for
 10G PHY
Date: Wed, 27 Nov 2013 10:41:32 -0800
Message-ID: <CAGVrzcbKt8jnwbWvaD_0gWKkZcQ-9kJkDba31EdrJvWqXiLPnQ@mail.gmail.com>
References: <1385459573-29092-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, jg1.han@samsung.com,
	mugunthanvnm@ti.com, netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Emilian.Medve@freescale.com, madalin.bucur@freescale.com
To: shh.xie@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1385459573-29092-1-git-send-email-shh.xie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2013/11/26  <shh.xie@gmail.com>:
> From: Shaohui Xie <Shaohui.Xie@freescale.com>
>
> Signed-off-by: Andy Fleming <afleming@freescale.com>
> Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
> v2: update of_net.c.
>
>  drivers/of/of_net.c | 1 +
>  include/linux/phy.h | 1 +
>  2 files changed, 2 insertions(+)
>
> diff --git a/drivers/of/of_net.c b/drivers/of/of_net.c
> index 8f9be2e..a208a45 100644
> --- a/drivers/of/of_net.c
> +++ b/drivers/of/of_net.c
> @@ -30,6 +30,7 @@ static const char *phy_modes[] = {
>         [PHY_INTERFACE_MODE_RGMII_TXID] = "rgmii-txid",
>         [PHY_INTERFACE_MODE_RTBI]       = "rtbi",
>         [PHY_INTERFACE_MODE_SMII]       = "smii",
> +       [PHY_INTERFACE_MODE_XGMII]      = "xgmii",
>  };
>
>  /**
> diff --git a/include/linux/phy.h b/include/linux/phy.h
> index 2549b42..2606599 100644
> --- a/include/linux/phy.h
> +++ b/include/linux/phy.h
> @@ -66,6 +66,7 @@ typedef enum {
>         PHY_INTERFACE_MODE_RGMII_TXID,
>         PHY_INTERFACE_MODE_RTBI,
>         PHY_INTERFACE_MODE_SMII,
> +       PHY_INTERFACE_MODE_XGMII,
>  } phy_interface_t;
>
>
> --
> 1.8.4.1
>
>



-- 
Florian
