From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH net-next 2/3] net: sh_eth: rename name structures as rcar_gen[12]_*
Date: Tue, 17 Oct 2017 10:20:07 +0200
Message-ID: <CAMuHMdXO-LWtTFOObMq0PZLC=cUPTH_cR7e5hsP_4dK7+6Ri-g@mail.gmail.com>
References: <20171017074747.24159-1-horms+renesas@verge.net.au> <20171017074747.24159-3-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Magnus Damm <magnus.damm@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>
To: Simon Horman <horms+renesas@verge.net.au>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20171017074747.24159-3-horms+renesas@verge.net.au>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 17, 2017 at 9:47 AM, Simon Horman
<horms+renesas@verge.net.au> wrote:
> Rename structures describing R-Car SoCs as rcar_gen[12]_*
> rather than r8a77[79]x_*. This seems a little easier on the
> eyes will make things slightly cleaner in a follow-up
> patch that adds fallback-compatibility strings for these SoCs.
>
> Note that R-Car Gen2 and RZ/G1 have many compatible IP blocks.  The
> approach that has been consistently taken for other IP blocks is to name
> common code, compatibility strings and so on after Rcar Gen2.
>
> Also rename sh_eth_set_rate_r8a777x as sh_eth_set_rate_rcar as
> it it is used by the R-Car generations supported by the driver.
>
> This patch should have no run-time effect and
> is compile-tested only.
>
> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

Reviewed-by: Geert Uytterhoeven <geert+renesas@glider.be>

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
