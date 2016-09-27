From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH resend] sh_eth: add R8A7743/5 support
Date: Tue, 27 Sep 2016 09:35:42 +0200
Message-ID: <CAMuHMdWq_714eP2q7V6AgopKu-mNx0GLUzyemad2H_ZcFt15ug@mail.gmail.com>
References: <1654835.SEcvPVx4OQ@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1654835.SEcvPVx4OQ@wasted.cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sergei,

On Tue, Sep 27, 2016 at 12:23 AM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> Add support for the first two members of the Renesas RZ/G family, RZ/G1M/E
> (also known as  R8A7743/5). The Ether core is the same as in the R-Car gen2
> SoCs, so will share the code/data with them...
>
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

> --- net-next.orig/drivers/net/ethernet/renesas/Kconfig
> +++ net-next/drivers/net/ethernet/renesas/Kconfig
> @@ -27,7 +27,7 @@ config SH_ETH
>           Renesas SuperH Ethernet device driver.
>           This driver supporting CPUs are:
>                 - SH7619, SH7710, SH7712, SH7724, SH7734, SH7763, SH7757,
> -                 R8A7740, R8A777x and R8A779x.
> +                 R8A7740, R8A774x, R8A777x and R8A779x.

Surely "R8A7740" is covered by "R8A774x"? :-)
However, the "x" is not a real wildcard (also for '7x and '9x), as the driver
doesn't support all possible values of "x".

Apart from that:
Acked-by: Geert Uytterhoeven <geert+renesas@glider.be>

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
