From: Biju Das <biju.das@bp.renesas.com>
Subject: RE: [PATCH v 1/2] ravb: Add support for r8a7743 SoC
Date: Mon, 10 Jul 2017 08:20:59 +0000
Message-ID: <KL1PR06MB1702B70F6F217FF33A103E7AB8A90@KL1PR06MB1702.apcprd06.prod.outlook.com>
References: <1499259711-56175-1-git-send-email-biju.das@bp.renesas.com>
 <1499259711-56175-2-git-send-email-biju.das@bp.renesas.com>
 <20170710012024.j4cso2jyi6canws2@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Mark Rutland <mark.rutland@arm.com>,
        Russell King <linux@armlinux.org.uk>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Simon Horman <horms@verge.net.au>,
        Magnus Damm <magnus.damm@gmail.com>,
        Chris Paterson <Chris.Paterson2@renesas.com>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        "linux-renesas-soc@vger.kernel.org"
        <linux-renesas-soc@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Rob Herring <robh@kernel.org>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20170710012024.j4cso2jyi6canws2@rob-hp-laptop>
Content-Language: en-US
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Thanks for the review.

> -----Original Message-----
> From: Rob Herring [mailto:robh@kernel.org]
> Sent: 10 July 2017 02:20
> To: Biju Das <biju.das@bp.renesas.com>
> Cc: Mark Rutland <mark.rutland@arm.com>; Russell King
> <linux@armlinux.org.uk>; Sergei Shtylyov
> <sergei.shtylyov@cogentembedded.com>; Simon Horman
> <horms@verge.net.au>; Magnus Damm <magnus.damm@gmail.com>; Chris
> Paterson <Chris.Paterson2@renesas.com>; devicetree@vger.kernel.org; linux=
-
> renesas-soc@vger.kernel.org; linux-arm-kernel@lists.infradead.org;
> netdev@vger.kernel.org
> Subject: Re: [PATCH v 1/2] ravb: Add support for r8a7743 SoC
>
> On Wed, Jul 05, 2017 at 02:01:50PM +0100, Biju Das wrote:
> > Add support for Gigabit Ethernet E-MAC on r8a7743 (RZ/G1M) SoC.
> > Renesas RZ/G1M (R8A7743) SoC Ethernet AVB IP is identical to the R-Car
> > Gen2 family.
>
> For the subject: "dt-bindings: net: ..."

I will change the subject to "dt-bindings: net: ravb: ..

>
> >
> > Signed-off-by: Biju Das <biju.das@bp.renesas.com>
> > Reviewed-by: Chris Paterson <chris.paterson2@renesas.com>
> > ---
> >  Documentation/devicetree/bindings/net/renesas,ravb.txt | 3 ++-
> >  drivers/net/ethernet/renesas/ravb_main.c               | 1 +
> >  2 files changed, 3 insertions(+), 1 deletion(-)
> >
> > diff --git a/Documentation/devicetree/bindings/net/renesas,ravb.txt
> > b/Documentation/devicetree/bindings/net/renesas,ravb.txt
> > index b519503..bc692ab 100644
> > --- a/Documentation/devicetree/bindings/net/renesas,ravb.txt
> > +++ b/Documentation/devicetree/bindings/net/renesas,ravb.txt
> > @@ -4,7 +4,8 @@ This file provides information on what the device node
> > for the Ethernet AVB  interface contains.
> >
> >  Required properties:
> > -- compatible: "renesas,etheravb-r8a7790" if the device is a part of R8=
A7790
> SoC.
> > +- compatible: "renesas,etheravb-r8a7743" if the device is a part of R8=
A7743
> SoC.
> > +      "renesas,etheravb-r8a7790" if the device is a part of R8A7790 So=
C.
>
> Please re-format like this:
>
> - compatible: Must be one of:
> ...
>
Ok. I will change this as well.

> So it's a one line change to add new compatibles.
>
> >        "renesas,etheravb-r8a7791" if the device is a part of R8A7791 So=
C.
> >        "renesas,etheravb-r8a7792" if the device is a part of R8A7792 So=
C.
> >        "renesas,etheravb-r8a7793" if the device is a part of R8A7793 So=
C.
> > diff --git a/drivers/net/ethernet/renesas/ravb_main.c
> > b/drivers/net/ethernet/renesas/ravb_main.c
> > index 5931e85..e35b30f 100644
> > --- a/drivers/net/ethernet/renesas/ravb_main.c
> > +++ b/drivers/net/ethernet/renesas/ravb_main.c
> > @@ -1869,6 +1869,7 @@ static int ravb_mdio_release(struct ravb_private
> > *priv)  }
> >
> >  static const struct of_device_id ravb_match_table[] =3D {
> > +{ .compatible =3D "renesas,etheravb-r8a7743", .data =3D (void
> > +*)RCAR_GEN2 },
> >  { .compatible =3D "renesas,etheravb-r8a7790", .data =3D (void
> *)RCAR_GEN2 },
> >  { .compatible =3D "renesas,etheravb-r8a7794", .data =3D (void
> *)RCAR_GEN2 },
> >  { .compatible =3D "renesas,etheravb-rcar-gen2", .data =3D (void
> > *)RCAR_GEN2 },
> > --
> > 1.9.1
> >



Renesas Electronics Europe Ltd, Dukes Meadow, Millboard Road, Bourne End, B=
uckinghamshire, SL8 5FH, UK. Registered in England & Wales under Registered=
 No. 04586709.
