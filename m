From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: Build regressions/improvements in v4.9-rc8
Date: Mon, 5 Dec 2016 11:24:43 +0100
Message-ID: <CAMuHMdV3999Y8pv5n-kCm6psXApH=cKdGe_R6G8atzgjgXi22A@mail.gmail.com>
References: <1480928996-7974-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480928996-7974-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 5, 2016 at 10:09 AM, Geert Uytterhoeven
<geert@linux-m68k.org> wrote:
> JFYI, when comparing v4.9-rc8[1] to v4.9-rc7[3], the summaries are:
>   - build errors: +5/-10

  + /home/kisskb/slave/src/drivers/net/ethernet/freescale/fec_main.c:
error: 'fec_stats' undeclared (first use in this function):  => 3296:7
  + /home/kisskb/slave/src/drivers/net/ethernet/freescale/fec_main.c:
error: implicit declaration of function
'fec_enet_update_ethtool_stats'
[-Werror=implicit-function-declaration]:  => 2887:2
  + /home/kisskb/slave/src/drivers/net/ethernet/freescale/fec_main.c:
error: negative width in bit-field '<anonymous>':  => 3296:7
  + /home/kisskb/slave/tmp/ccJlHrOq.s: Error: pcrel too far
BFD_RELOC_BFIN_10:  => 912

m68k/m5272c3_defconfig (patch available)

> [1] http://kisskb.ellerman.id.au/kisskb/head/3e5de27e940d00d8d504dfb96625fb654f641509/ (all 267 configs)
> [3] http://kisskb.ellerman.id.au/kisskb/head/e5517c2a5a49ed5e99047008629f1cd60246ea0e/ (all 267 configs)

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
