From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] fsl/fman: add dependency on HAS_DMA
Date: Mon, 26 Jun 2017 18:17:22 +0200
Message-ID: <CAMuHMdW54XAVGvx14286Ot5itGoTPPfaWA75fJH4PhVz9UQwUQ@mail.gmail.com>
References: <1498489947-17272-1-git-send-email-madalin.bucur@nxp.com> <CAOMZO5AWgPv6bOFjpt4vC1PSMNpC+dpR2A90+fc2Z_uojoUAmA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: madalin.bucur@nxp.com,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAOMZO5AWgPv6bOFjpt4vC1PSMNpC+dpR2A90+fc2Z_uojoUAmA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 26, 2017 at 5:20 PM, Fabio Estevam <festevam@gmail.com> wrote:
> On Mon, Jun 26, 2017 at 12:12 PM, Madalin Bucur <madalin.bucur@nxp.com> wrote:
>> A previous commit inserted a dependency on DMA API that requires
>> HAS_DMA to be added in Kconfig.
>
> It would be nice to specify the commit that caused this.

That would be commit 5567e989198b5a8d ("fsl/fman: propagate dma_ops").

However, none of the fman code uses any DMA API calls, so IMHO
the set_dma_ops() should be done somewhere else.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
