From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH can-next 2/2] CAN: rcar: add device tree support for
 r8a779[234]
Date: Tue, 23 Feb 2016 09:02:00 +0900
Message-ID: <20160223000200.GD1853@verge.net.au>
References: <1456107350-12100-1-git-send-email-horms+renesas@verge.net.au>
 <1456107350-12100-3-git-send-email-horms+renesas@verge.net.au>
 <CAMuHMdU5zMG=Sha5MfotbKmdBDgzJucve483oZbmseLvLR-2sA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Magnus Damm <magnus.damm@gmail.com>, linux-can@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-renesas-soc@vger.kernel.org,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAMuHMdU5zMG=Sha5MfotbKmdBDgzJucve483oZbmseLvLR-2sA@mail.gmail.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 22, 2016 at 02:48:39PM +0100, Geert Uytterhoeven wrote:
> On Mon, Feb 22, 2016 at 3:15 AM, Simon Horman
> <horms+renesas@verge.net.au> wrote:
> > Simply document new compatibility string.
> > As a previous patch adds a generic R-Car Gen2 compatibility string
> > there appears to be no need for a driver updates.
> > By documenting this compat sting it may be used in DTSs shipped, for
> 
> string
> 
> > example as part of ROMs. It must be used in conjunction with the Gen2
> > fallback compat string. At this time there are no known differences between
> > the r8a779[234] IP blocks and that implemented by the driver for the Gen2
> > fallback compat string. Thus there is no need to update the driver as the
>                           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> > use of the Gen2 fallback compat string will activate the correct code in
>   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> 
> > the current driver while leaving the option for r8a779[234]-specific driver
> > code to be activated in an updated driver should the need arise.
> >
> > Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
> > ---
> >  Documentation/devicetree/bindings/net/can/rcar_can.txt | 3 +++
> >  drivers/net/can/rcar_can.c                             | 3 +++
> >  2 files changed, 6 insertions(+)
> >
> > diff --git a/Documentation/devicetree/bindings/net/can/rcar_can.txt b/Documentation/devicetree/bindings/net/can/rcar_can.txt
> > index 036786e1f70d..c6fb74d7c809 100644
> > --- a/Documentation/devicetree/bindings/net/can/rcar_can.txt
> > +++ b/Documentation/devicetree/bindings/net/can/rcar_can.txt
> > @@ -6,6 +6,9 @@ Required properties:
> >               "renesas,can-r8a7779" if CAN controller is a part of R8A7779 SoC.
> >               "renesas,can-r8a7790" if CAN controller is a part of R8A7790 SoC.
> >               "renesas,can-r8a7791" if CAN controller is a part of R8A7791 SoC.
> > +             "renesas,can-r8a7792" if CAN controller is a part of R8A7792 SoC.
> > +             "renesas,can-r8a7793" if CAN controller is a part of R8A7793 SoC.
> > +             "renesas,can-r8a7794" if CAN controller is a part of R8A7794 SoC.
> >               "renesas,can-gen1" for a generic R-Car Gen1 compatible device.
> >               "renesas,can-gen2" for a generic R-Car Gen2 compatible device.
> >  - reg: physical base address and size of the R-Car CAN register map.
> > diff --git a/drivers/net/can/rcar_can.c b/drivers/net/can/rcar_can.c
> > index c70a1f795933..73761a4dd1bf 100644
> > --- a/drivers/net/can/rcar_can.c
> > +++ b/drivers/net/can/rcar_can.c
> > @@ -904,6 +904,9 @@ static const struct of_device_id rcar_can_of_table[] __maybe_unused = {
> >         { .compatible = "renesas,can-r8a7779" },
> >         { .compatible = "renesas,can-r8a7790" },
> >         { .compatible = "renesas,can-r8a7791" },
> > +       { .compatible = "renesas,can-r8a7792" },
> > +       { .compatible = "renesas,can-r8a7793" },
> > +       { .compatible = "renesas,can-r8a7794" },
> 
> So why do you update the driver?
> 
> There's no upstream DTS using "renesas,can-r8a779[234]", so
> "renesas,can-gen2" should be fine.

True. I'm not sure how that slipped in.

> >         { .compatible = "renesas,can-gen1" },
> >         { .compatible = "renesas,can-gen2" },
> >         { }
> 
> Gr{oetje,eeting}s,
> 
>                         Geert
> 
> --
> Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org
> 
> In personal conversations with technical people, I call myself a hacker. But
> when I'm talking to journalists I just say "programmer" or something like that.
>                                 -- Linus Torvalds
