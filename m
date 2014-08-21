From: Zhi Li <lznuaa@gmail.com>
Subject: Re: [PATCH 1/1] net:fec: buffer descriptor member variable order in IMX6
Date: Thu, 21 Aug 2014 14:30:12 -0500
Message-ID: <CAHrpEqTtsLk3x3ocHSXh3C1ysvqq+RSg-sD0YZ5O8iuZfMYvEg@mail.gmail.com>
References: <1408612915-8657-1-git-send-email-Yanjun.Zhu@windriver.com>
	<1408612915-8657-2-git-send-email-Yanjun.Zhu@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kernel list <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Zhu Yanjun <Yanjun.Zhu@windriver.com>,
	Frank Li <Frank.Li@freescale.com>
To: Zhu Yanjun <zyjzyj2000@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408612915-8657-2-git-send-email-Yanjun.Zhu@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 21, 2014 at 4:21 AM, Zhu Yanjun <zyjzyj2000@gmail.com> wrote:
> From Reference Manual, freescale IMX6 is little endian mode. Therefore
> the first structure field is length, the second is status.
>
> CC: David Miller <davem@davemloft.net>
> CC: Frank Li <Frank.Li@freescale.com>
> Signed-off-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>
> ---
>  drivers/net/ethernet/freescale/fec.h | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
> index 671d080..96a5f8a 100644
> --- a/drivers/net/ethernet/freescale/fec.h
> +++ b/drivers/net/ethernet/freescale/fec.h
> @@ -147,7 +147,8 @@
>  /*
>   *     Define the buffer descriptor structure.
>   */
> -#if defined(CONFIG_ARCH_MXC) || defined(CONFIG_SOC_IMX28)
> +#if defined(CONFIG_ARCH_MXC) || defined(CONFIG_SOC_IMX28) || \
> +                       defined(CONFIG_ARCH_MX6)

CONFIG_ARCH_MXC already included CONFIG_ARCH_MX6
ARCH_MXC included whole MX serial, MX35, MX5x, MX6x.

IMX28 is special, coming from sigmatel chip.

So it is not necessary to add ARCH_MX6


Best regards
Frank Li

>  struct bufdesc {
>         unsigned short cbd_datlen;      /* Data length */
>         unsigned short cbd_sc;  /* Control and status info */
> --
> 1.9.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
