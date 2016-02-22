From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH can-next 1/2] CAN: rcar: add gen[12] fallback
 compatibility strings
Date: Mon, 22 Feb 2016 10:40:37 +0100
Message-ID: <56CAD795.1090509@pengutronix.de>
References: <1456107350-12100-1-git-send-email-horms+renesas@verge.net.au>
 <1456107350-12100-2-git-send-email-horms+renesas@verge.net.au>
 <20160222033720.GA27711@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="TFsQp3vfDkNDOVfnr997vimPE2SxC5Rmr"
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Magnus Damm <magnus.damm@gmail.com>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
	devicetree@vger.kernel.org
To: Rob Herring <robh@kernel.org>,
	Simon Horman <horms+renesas@verge.net.au>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20160222033720.GA27711@rob-hp-laptop>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--TFsQp3vfDkNDOVfnr997vimPE2SxC5Rmr
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 02/22/2016 04:37 AM, Rob Herring wrote:
> On Mon, Feb 22, 2016 at 11:15:49AM +0900, Simon Horman wrote:
>> Add fallback compatibility string for R-Car Gen 1 and Gen2 families.
>> This is in keeping with the fallback scheme being adopted wherever
>> appropriate for drivers for Renesas SoCs.
>>
>> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
>> ---
>>  Documentation/devicetree/bindings/net/can/rcar_can.txt | 4 +++-
>>  drivers/net/can/rcar_can.c                             | 2 ++
>>  2 files changed, 5 insertions(+), 1 deletion(-)
>=20
> Acked-by: Rob Herring <robh@kernel.org>

I'm not following the latest DT discussions, is there a (new) decision
to add such "generic" compatibles? AFAIK you add the oldest device
that's compatible with your driver to your SoC dtsi at rightmost
compatible. You can add one that identifies your SoC's IP core in front
of it. So there's no need to modify the driver until an IP core needs
different handling.

In your case you'd identify the oldest SoC that implements the Gen1 IP
core and use this instead of "renesas,can-gen1. Same for Gen2 IP core.

regards,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--TFsQp3vfDkNDOVfnr997vimPE2SxC5Rmr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJWyteWAAoJED07qiWsqSVqobgH/iTIGnWrCF1Bxcp9CJQ+/7NT
u3E0NCDK+TcePKtUT1gknSRjGslaTmIuUqw/6zdLL76WkD8paM5p07vPIMCrkKSv
QMprS6QHpgd18seJxqMl7/Zy66As+RtOw+sGnaeIS/TBHItok+D7MQ8ecPpRm+xL
8yxZ8hBcnr/umGDXW+cpOTEBW7wYfabiGUA/a+/vOMbBaAHbFdf+8lvsvRwufkRJ
hSUhCUrk8a7893z/KkjTgECVr37WUM5H1apEcibPcbpoTyN4K2iPhB4EVoTLej9c
M/7YuBywOul0kC/Frd+M6j4+236bf82BO+OXLzw0ULVS5+Z+w6PMj3jEWuJhSrI=
=crVv
-----END PGP SIGNATURE-----

--TFsQp3vfDkNDOVfnr997vimPE2SxC5Rmr--
