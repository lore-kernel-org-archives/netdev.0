From: Kumar Gala <galak@codeaurora.org>
Subject: Re: [PATCH 3/3] can: mcp251x: Add device tree support
Date: Wed, 13 Nov 2013 04:53:02 -0600
Message-ID: <7E7A9748-D946-4FDD-A764-6C7ECA44B890@codeaurora.org>
References: <1384332341-15363-1-git-send-email-shc_work@mail.ru>
Mime-Version: 1.0 (Mac OS X Mail 7.0 \(1822\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Rob Herring <rob.herring@calxeda.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Stephen Warren <swarren@wwwdotorg.org>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>
To: Alexander Shiyan <shc_work@mail.ru>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1384332341-15363-1-git-send-email-shc_work@mail.ru>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Nov 13, 2013, at 2:45 AM, Alexander Shiyan <shc_work@mail.ru> wrote:

> This patch adds Device Tree support to the Microchip MCP251X driver.
>=20
> Signed-off-by: Alexander Shiyan <shc_work@mail.ru>
> ---
> .../bindings/net/can/microchip,mcp251x.txt         | 25 ++++++++++
> drivers/net/can/mcp251x.c                          | 57 +++++++++++++=
+++------
> 2 files changed, 66 insertions(+), 16 deletions(-)
> create mode 100644 Documentation/devicetree/bindings/net/can/microchi=
p,mcp251x.txt
>=20
> diff --git a/Documentation/devicetree/bindings/net/can/microchip,mcp2=
51x.txt b/Documentation/devicetree/bindings/net/can/microchip,mcp251x.t=
xt
> new file mode 100644
> index 0000000..06d95ee
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/can/microchip,mcp251x.txt
> @@ -0,0 +1,25 @@
> +* Microchip MCP251X device tree bindings
> +
> +Registers a Microchip MCP251X stand-alone CAN controller connected t=
o SPI bus.

=93Register a=94 doesn=92t seem like it should be in a binding spec.

> +
> +Required properties:
> + - compatible: Should be one of the following:
> +   - "microchip,mcp2510" for MCP2510.
> +   - "microchip,mcp2515" for MCP2515.
> + - reg: SPI chip select.
> + - clocks: The clock feeding the CAN controller.
> + - interrupt-parent: The parent interrupt controller.
> + - interrupts: Should contain IRQ line for the CAN controller.
> +
> +Optional properties:
> + - vdd-supply: Regulator that powers the CAN controller.
> + - xceiver-supply: Regulator that powers the CAN transceiver.
> +
> +Example:
> +	can0: can@1 {
> +		compatible =3D "microchip,mcp2515";
> +		reg =3D <1>;
> +		clocks =3D <&clk24m>;
> +		interrupt-parent =3D <&gpio4>;
> +		interrupts =3D <13 0x2>;

Usually good to have example show all properties used (even optional on=
es)

> +	};

Other than the nits, binding looks good.

- k

--=20
Employee of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, host=
ed by The Linux Foundation

