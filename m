From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH v7 1/2] can: xilinx CAN controller support
Date: Mon, 07 Apr 2014 08:56:50 +0200
Message-ID: <53424C32.7090000@monstr.eu>
References: <3e750ec3-9d47-4b4e-8173-56698ab19786@CH1EHSMHS029.ehs.local>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="WtPjUIdcbAiEAWTVRw2qqJmVhPaiGXxNM"
Cc: wg@grandegger.com, mkl@pengutronix.de, michal.simek@xilinx.com,
	grant.likely@linaro.org, robh+dt@kernel.org,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org,
	Kedareswara rao Appana <appanad@xilinx.com>
To: Kedareswara rao Appana <appana.durga.rao@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3e750ec3-9d47-4b4e-8173-56698ab19786@CH1EHSMHS029.ehs.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--WtPjUIdcbAiEAWTVRw2qqJmVhPaiGXxNM
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 04/02/2014 03:13 PM, Kedareswara rao Appana wrote:
> This patch adds xilinx CAN controller support.
> This driver supports both ZYNQ CANPS and Soft IP
> AXI CAN controller.
>=20
> Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
> ---
> Changes for v7:
> - Updated the driver with review comments.
> - Moved the driver bindings doc as a separte patch.
> Changes for v6:
> - Updated the driver with review comments.
> - Used the clock names specified in the data sheet.
> - Updated the devicetree bindings doc as per Rob suggestion.
> Changes for v5:
> - Updated the driver with the review comments.
> - Remove the check for the tx fifo full interrupt condition
>   form Tx interrupt routine as we are checking it in the _xmit
>   routine.
> - Clearing the txok interrupt in the tx interrupt routine for
>   every Tx can frame.
> Changes for v4:
> - Added check for the tx fifo full interrupt condition in
> Tx interrupt routine.
> - Added be iohelper functions.
> - Moved the clock enable/disable to probe/remove because of
>   Added big endian support for AXI CAN controller case(reading
>   a register during probe for that we need to enable clock).
> Changes for v3:
> - Updated the driver with the review comments.
> - Modified the tranmit logic as per Marc suggestion.
> - Enabling the clock when the interface is up to reduce the
>   Power consumption.
> Changes for v2:
> - Updated with the review comments.
> - Removed the unnecessary debug prints.
> - include tx,rx fifo depths in ZYNQ CANPS case also
> ---
>  drivers/net/can/Kconfig      |    7 +
>  drivers/net/can/Makefile     |    1 +
>  drivers/net/can/xilinx_can.c | 1176 ++++++++++++++++++++++++++++++++++=
++++++++
>  3 files changed, 1184 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/can/xilinx_can.c

Mark: Any update on this one?
BTW: When you apply these patches you should apply 2/2 before 1/2. There =
is
new checking for binding.

Thanks,
Michal

--=20
Michal Simek, Ing. (M.Eng), OpenPGP -> KeyID: FE3D1F91
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel - Microblaze cpu - http://www.monstr.eu/fdt/
Maintainer of Linux kernel - Xilinx Zynq ARM architecture
Microblaze U-BOOT custodian and responsible for u-boot arm zynq platform



--WtPjUIdcbAiEAWTVRw2qqJmVhPaiGXxNM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlNCTDIACgkQykllyylKDCG1EgCeLE2XknDSTycp+m4/LnRJNFgf
Ht0An3Z5dCr0Dd/TEcg1ZoPKU0OIAYo+
=0rwI
-----END PGP SIGNATURE-----

--WtPjUIdcbAiEAWTVRw2qqJmVhPaiGXxNM--
