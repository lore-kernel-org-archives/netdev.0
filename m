From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH 1/2 net-next] ravb: Add fallback compatibility strings
Date: Tue, 1 Dec 2015 09:42:52 +0100
Message-ID: <CAMuHMdW_PagMbAqrvM-_-sJumhMPoYGobNF485Q1D+CRQ5j+bQ@mail.gmail.com>
References: <1448955783-22806-1-git-send-email-horms+renesas@verge.net.au>
	<1448955783-22806-2-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>,
	Magnus Damm <magnus.damm@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Simon Horman <horms+renesas@verge.net.au>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1448955783-22806-2-git-send-email-horms+renesas@verge.net.au>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 1, 2015 at 8:43 AM, Simon Horman <horms+renesas@verge.net.au> wrote:
> Add fallback compatibility strings for R-Car Gen 2 & 3 SoC Families.
> This is in keeping with the fallback scheme being adopted wherever
> appropriate for drivers for Renesas SoCs.
>
> Also correct typo.
>
> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
> ---
>  Documentation/devicetree/bindings/net/renesas,ravb.txt | 11 +++++++++--
>  drivers/net/ethernet/renesas/ravb_main.c               |  2 ++
>  2 files changed, 11 insertions(+), 2 deletions(-)
>
> diff --git a/Documentation/devicetree/bindings/net/renesas,ravb.txt b/Documentation/devicetree/bindings/net/renesas,ravb.txt
> index b486f3f5f6a3..115006325bff 100644
> --- a/Documentation/devicetree/bindings/net/renesas,ravb.txt
> +++ b/Documentation/devicetree/bindings/net/renesas,ravb.txt
> @@ -1,12 +1,19 @@
>  * Renesas Electronics Ethernet AVB
>
>  This file provides information on what the device node for the Ethernet AVB
> -interface contains.
> +interface.
>
>  Required properties:
>  - compatible: "renesas,etheravb-r8a7790" if the device is a part of R8A7790 SoC.
>               "renesas,etheravb-r8a7794" if the device is a part of R8A7794 SoC.
>               "renesas,etheravb-r8a7795" if the device is a part of R8A7795 SoC.
> +             "renesas,etheravb-gen2" for generic R-Car Gen 2 compatible interface.
> +             "renesas,etheravb-gen3" for generic R-Car Gen 3 compatible interface.
> +

(Same comment, different audience)

Shouldn't that be "renesas,etheravb-rcar-gen" or "renesas,etheravb-rcar2"?

Else you'll be in trouble when Renesas starts focussing on airplanes
(R-Plane Gen2), rockets (R-Rocket Gen2), or IoT (R-IoT Gen2).

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
