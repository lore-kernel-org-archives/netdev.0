From: Harini Katakam <harinikatakamlinux@gmail.com>
Subject: Re: [net-next PATCH 3/3] net: macb: Add change_mtu callback with
 jumbo support
Date: Fri, 10 Apr 2015 15:05:28 +0530
Message-ID: <CAFcVECLONoSV8riBHpkhJXrx39wtDLP2X7zx=C6jdXGuqw_vAg@mail.gmail.com>
References: <1428657441-27710-1-git-send-email-harinik@xilinx.com>
	<9376b508-694b-4582-8f2c-4e85e2bab2b5@BY2FFO11FD054.protection.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: nicolas.ferre@atmel.com, davem@davemloft.net,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	boris.brezillon@free-electrons.com,
	alexandre.belloni@free-electrons.com, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Punnaiah Choudary Kalluri <punnaia@xilinx.com>,
	"michals@xilinx.com" <michals@xilinx.com>
To: Harini Katakam <harini.katakam@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <9376b508-694b-4582-8f2c-4e85e2bab2b5@BY2FFO11FD054.protection.gbl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 10, 2015 at 2:47 PM, Harini Katakam
<harini.katakam@xilinx.com> wrote:
> Add macb_change_mtu callback; if jumbo frame support is present allow
> mtu size changes upto (jumbo max length allowed - headers).
>
> Signed-off-by: Harini Katakam <harinik@xilinx.com>
> Reviewed-by: Punnaiah Choudary Kalluri <punnaia@xilinx.com>
> ---
>  drivers/net/ethernet/cadence/macb.c |   26 +++++++++++++++++++++++++-
>  1 file changed, 25 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index 85de91d..33f3283 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -54,6 +54,10 @@
>  #define MACB_MAX_TX_LEN                ((unsigned int)((1 << MACB_TX_FRMLEN_SIZE) - 1))
>  #define GEM_MAX_TX_LEN         ((unsigned int)((1 << GEM_TX_FRMLEN_SIZE) - 1))
>
> +#define GEM_MTU_MIN_SIZE       68
> +
> +#define GEM_ZYNQMP_JUMBO_MAX   10240

I'm sorry - this definition is in the wrong patch. I'll correct it and
send a v2.

Regards,
Harini
