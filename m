From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH can-next v2 1/2] CAN: rcar: add gen[12] fallback
 compatibility strings
Date: Wed, 24 Feb 2016 08:36:38 +0100
Message-ID: <CAMuHMdXy0Y2NtPzL9RuhPnu2qPd1-Ft75xfNOmj1EN0Rbq3Jsg@mail.gmail.com>
References: <1456278993-9899-1-git-send-email-horms+renesas@verge.net.au>
	<1456278993-9899-2-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Magnus Damm <magnus.damm@gmail.com>, linux-can@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-renesas-soc@vger.kernel.org
To: Simon Horman <horms+renesas@verge.net.au>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1456278993-9899-2-git-send-email-horms+renesas@verge.net.au>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 24, 2016 at 2:56 AM, Simon Horman
<horms+renesas@verge.net.au> wrote:
> Add fallback compatibility string for R-Car Gen 1 and Gen2.
>
> In the case of Renesas R-Car hardware we know that there are generations of
> SoCs, e.g. Gen 1 and Gen 2. But beyond that its not clear what the
> relationship between IP blocks might be. For example, I believe that
> r8a7779 is older than r8a7778 but that doesn't imply that the latter is a
> descendant of the former or vice versa.
>
> We can, however, by examining the documentation and behaviour of the
> hardware at run-time observe that the current driver implementation appears
> to be compatible with the IP blocks on SoCs within a given generation.
>
> For the above reasons and convenience when enabling new SoCs a
> per-generation fallback compatibility string scheme being adopted for
> drivers for Renesas SoCs.
>
> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
> Acked-by: Rob Herring <robh@kernel.org>

Acked-by: Geert Uytterhoeven <geert+renesas@glider.be>

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
