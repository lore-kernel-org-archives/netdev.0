From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH v2 1/3] net/macb: Update DT bindings documentation
Date: Fri, 6 Mar 2015 17:45:00 +0100
Message-ID: <54F9D98C.2020807@atmel.com>
References: <1425637442-8724-1-git-send-email-boris.brezillon@free-electrons.com> <1425637442-8724-2-git-send-email-boris.brezillon@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
	"Alexandre Belloni" <alexandre.belloni@free-electrons.com>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	"Kumar Gala" <galak@codeaurora.org>, <devicetree@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Boris Brezillon <boris.brezillon@free-electrons.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425637442-8724-2-git-send-email-boris.brezillon@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 06/03/2015 11:24, Boris Brezillon a =E9crit :
> Add missing "cdns,at91sam9260-macb", "atmel,sama5d3-gem" and
> "atmel,sama5d4-gem" compatible strings.
>=20
> Signed-off-by: Boris Brezillon <boris.brezillon@free-electrons.com>
> Reviewed-by: Alexandre Belloni <alexandre.belloni@free-electrons.com>

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

> ---
>  Documentation/devicetree/bindings/net/macb.txt | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
>=20
> diff --git a/Documentation/devicetree/bindings/net/macb.txt b/Documen=
tation/devicetree/bindings/net/macb.txt
> index aaa6964..ba19d67 100644
> --- a/Documentation/devicetree/bindings/net/macb.txt
> +++ b/Documentation/devicetree/bindings/net/macb.txt
> @@ -2,10 +2,13 @@
> =20
>  Required properties:
>  - compatible: Should be "cdns,[<chip>-]{macb|gem}"
> -  Use "cdns,at91sam9260-macb" Atmel at91sam9260 and at91sam9263 SoCs=
=2E
> +  Use "cdns,at91sam9260-macb" for Atmel at91sam9 SoCs or the 10/100M=
bit IP
> +  available on sama5d3 SoCs.
>    Use "cdns,at32ap7000-macb" for other 10/100 usage or use the gener=
ic form: "cdns,macb".
>    Use "cdns,pc302-gem" for Picochip picoXcell pc302 and later device=
s based on
>    the Cadence GEM, or the generic form: "cdns,gem".
> +  Use "cdns,sama5d3-gem" for the Gigabit IP available on Atmel sama5=
d3 SoCs.
> +  Use "cdns,sama5d4-gem" for the Gigabit IP available on Atmel sama5=
d4 SoCs.
>  - reg: Address and length of the register set for the device
>  - interrupts: Should contain macb interrupt
>  - phy-mode: See ethernet.txt file in the same directory.
>=20


--=20
Nicolas Ferre
