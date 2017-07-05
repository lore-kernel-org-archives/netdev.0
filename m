From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH v 1/2] ravb: Add support for r8a7743 SoC
Date: Wed, 5 Jul 2017 15:47:13 +0200
Message-ID: <CAMuHMdVMunZ0trcNmMg4KkEd+d88foep7C0kU=yLQNk5JojosA@mail.gmail.com>
References: <1499259711-56175-1-git-send-email-biju.das@bp.renesas.com> <1499259711-56175-2-git-send-email-biju.das@bp.renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Russell King <linux@armlinux.org.uk>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Simon Horman <horms@verge.net.au>,
        Magnus Damm <magnus.damm@gmail.com>,
        Chris Paterson <chris.paterson2@renesas.com>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Biju Das <biju.das@bp.renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:32967 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751599AbdGENrO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 09:47:14 -0400
In-Reply-To: <1499259711-56175-2-git-send-email-biju.das@bp.renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Biju,

On Wed, Jul 5, 2017 at 3:01 PM, Biju Das <biju.das@bp.renesas.com> wrote:
> Add support for Gigabit Ethernet E-MAC on r8a7743 (RZ/G1M) SoC.
> Renesas RZ/G1M (R8A7743) SoC Ethernet AVB IP is identical to the R-Car Gen2
> family.
>
> Signed-off-by: Biju Das <biju.das@bp.renesas.com>
> Reviewed-by: Chris Paterson <chris.paterson2@renesas.com>

Thanks for your patch!

> --- a/drivers/net/ethernet/renesas/ravb_main.c
> +++ b/drivers/net/ethernet/renesas/ravb_main.c
> @@ -1869,6 +1869,7 @@ static int ravb_mdio_release(struct ravb_private *priv)
>  }
>
>  static const struct of_device_id ravb_match_table[] = {
> +       { .compatible = "renesas,etheravb-r8a7743", .data = (void *)RCAR_GEN2 },
>         { .compatible = "renesas,etheravb-r8a7790", .data = (void *)RCAR_GEN2 },
>         { .compatible = "renesas,etheravb-r8a7794", .data = (void *)RCAR_GEN2 },
>         { .compatible = "renesas,etheravb-rcar-gen2", .data = (void *)RCAR_GEN2 },

As Sergei already mentioned, a driver update is not needed due to the
presence of family-specific compatible values.
Please drop that part, and you can add my:
Reviewed-by: Geert Uytterhoeven <geert+renesas@glider.be>

Gr{oetje,eeting}s,

                        Geert
