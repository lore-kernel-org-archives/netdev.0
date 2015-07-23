From: Harini Katakam <harinikatakamlinux@gmail.com>
Subject: Re: [NET-NEXT PATCH] net: macb: Change capability mask of jumbo support
Date: Thu, 23 Jul 2015 15:35:08 +0530
Message-ID: <CAFcVECJ1egvteE6DazZg-1enAmhY5Opv9TYyHEsjS_YuXaZGYA@mail.gmail.com>
References: <1437645686-5146-1-git-send-email-harinik@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>, davem@davemloft.net,
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
In-Reply-To: <1437645686-5146-1-git-send-email-harinik@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please ignore this patch. This is not on the right base, i'll resend it.

Regards,
Harini

On Thu, Jul 23, 2015 at 3:31 PM, Harini Katakam
<harini.katakam@xilinx.com> wrote:
> Capability mask for jumbo and no gigabit half duplex is the same.
> Change one of them.
>
> Signed-off-by: Harini Katakam <harinik@xilinx.com>
> ---
>  drivers/net/ethernet/cadence/macb.h |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
> index 15fd6e3..8b3087b 100644
> --- a/drivers/net/ethernet/cadence/macb.h
> +++ b/drivers/net/ethernet/cadence/macb.h
> @@ -449,7 +449,7 @@
>  #define MACB_CAPS_GIGABIT_MODE_AVAILABLE       0x20000000
>  #define MACB_CAPS_SG_DISABLED                  0x40000000
>  #define MACB_CAPS_MACB_IS_GEM                  0x80000000
> -#define MACB_CAPS_JUMBO                                0x00000008
> +#define MACB_CAPS_JUMBO                                0x00000010
>  #define NS_PER_SEC                             1000000000ULL
>
>  /* Bit manipulation macros */
> --
> 1.7.9.5
>
