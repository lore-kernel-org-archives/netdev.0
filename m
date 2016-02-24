From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH can-next v2 2/2] CAN: rcar: add device tree support for r8a779[234]
Date: Wed, 24 Feb 2016 08:35:41 +0100
Message-ID: <CAMuHMdXHcOMg8jAEV5o4kkrW8amF5cgE529k8cTb-V3CJasV-A@mail.gmail.com>
References: <1456278993-9899-1-git-send-email-horms+renesas@verge.net.au>
	<1456278993-9899-3-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Magnus Damm <magnus.damm@gmail.com>, linux-can@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-renesas-soc@vger.kernel.org
To: Simon Horman <horms+renesas@verge.net.au>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1456278993-9899-3-git-send-email-horms+renesas@verge.net.au>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 24, 2016 at 2:56 AM, Simon Horman
<horms+renesas@verge.net.au> wrote:
> Simply document new compatibility string.
> As a previous patch adds a generic R-Car Gen2 compatibility string
> there appears to be no need for a driver updates.
>
> By documenting these compat stings they may be used in DTSs shipped, for
> example as part of ROMs. They must be used in conjunction with the Gen2
> fallback compat string. At this time there are no known differences between
> the r8a779[234] IP blocks and that implemented by the driver for the Gen2
> fallback compat string. Thus there is no need to update the driver as the
> use of the Gen2 fallback compat string will activate the correct code in
> the current driver while leaving the option for r8a779[234]-specific driver
> code to be activated in an updated driver should the need arise.
>
> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

Acked-by: Geert Uytterhoeven <geert+renesas@glider.be>

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
