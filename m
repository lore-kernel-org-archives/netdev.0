From: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>
Subject: RE: [PATCH] can: rcar_canfd: Correct order of interrupt specifiers
Date: Wed, 23 Nov 2016 14:04:38 +0000
Message-ID: <SG2PR06MB103872ECF569059335DA7AD0C3B70@SG2PR06MB1038.apcprd06.prod.outlook.com>
References: <1479908686-14028-1-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        "linux-renesas-soc@vger.kernel.org"
        <linux-renesas-soc@vger.kernel.org>
To: Geert Uytterhoeven <geert+renesas@glider.be>,
        Wolfgang Grandegger <wg@grandegger.com>,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        Chris Paterson <Chris.Paterson2@renesas.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1479908686-14028-1-git-send-email-geert+renesas@glider.be>
Content-Language: en-US
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Geert,

> Subject: [PATCH] can: rcar_canfd: Correct order of interrupt specifiers
>=20
> According to both DTS (example and actual files), and Linux driver code,
> the first interrupt specifier should be the Channel interrupt, while the
> second interrupt specifier should be the Global interrupt.
>=20
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
> ---
>  Documentation/devicetree/bindings/net/can/rcar_canfd.txt | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/Documentation/devicetree/bindings/net/can/rcar_canfd.txt
> b/Documentation/devicetree/bindings/net/can/rcar_canfd.txt
> index 22a6f10bab057f46..58c27cd839e3a2ac 100644
> --- a/Documentation/devicetree/bindings/net/can/rcar_canfd.txt
> +++ b/Documentation/devicetree/bindings/net/can/rcar_canfd.txt
> @@ -11,7 +11,7 @@ Required properties:
>    family-specific and/or generic versions.
>=20
>  - reg: physical base address and size of the R-Car CAN FD register map.
> -- interrupts: interrupt specifier for the Global & Channel interrupts
> +- interrupts: interrupt specifiers for the Channel & Global interrupts

Thanks for correcting it.
Acked-by: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>

Thanks,
Ramesh
