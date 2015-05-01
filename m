From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] net: can: xilinx_can: fix extended frame handling
Date: Fri, 1 May 2015 10:20:35 +0200
Message-ID: <55433753.5050500@pengutronix.de>
References: <1430319901-19242-1-git-send-email-jlp@gomspace.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="VrAC3rOdDewjQiMp5TqwgniDd1UPQ4KMK"
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeppe Ledet-Pedersen <jlp@gomspace.com>, wg@grandegger.com,
	michal.simek@xilinx.com, soren.brinkmann@xilinx.com,
	appana.durga.rao@xilinx.com
Return-path: <linux-kernel-owner@vger.kernel.org>
in-reply-to: <1430319901-19242-1-git-send-email-jlp@gomspace.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--VrAC3rOdDewjQiMp5TqwgniDd1UPQ4KMK
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 04/29/2015 05:05 PM, Jeppe Ledet-Pedersen wrote:
> Using IDR_SRR in RXFIFO_ID to test for the presence of data is only
> valid for standard frames. For extended frames the bit is always 1 and
> IDR_RTR should be used instead. This patch switches the check to use
> CAN_RTR_FLAG which is correctly set when reading the ID.
>=20
> The patch also changes the DW1/DW2 to be read unconditionally, since
> this is necessary to remove the frame from the RXFIFO.
>=20
> Signed-off-by: Jeppe Ledet-Pedersen <jlp@gomspace.com>
> Acked-by: Kedareswara rao Appana <appanad@xilinx.com>

Applied to can. Added stable on Cc.

Thanks,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--VrAC3rOdDewjQiMp5TqwgniDd1UPQ4KMK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCgAGBQJVQzdTAAoJECte4hHFiupU4uMP/3eoNURgmLd6dBWV/4xF9o5n
E0lo6pCl3DNeBIbH43AnLwGoBTQ93JfAixRj6Y+ro4c7GEAlmEq58uykYhXfWhTB
nzum8UrKZxh/g4+zqzCuWZoiXPITbZ9Abbcw8p6fXIWx9+xxvDcUXKsY1l3D/ZO6
5QSafUiG/dg0x87zHDm3H8FKTObpYEkdey/T69dhtSydt51WupSyfp4pmxNoXCvW
3x6Lzb0HRoHL2n7P1BG6Xux/JOndREx8EL05FjvHYWVramiSmqOBL1immwW8+KRv
gKLrjmKN9AIBf1ml3Ot2MxDqlvaTpqh0nuTKfh3RQ/bM6MJkxns5oVP9UjkCEABM
3FH5hTpIVnm2iyRSQGXAi+RTTk8Kqqd6SdAAuR/EzRn3eDx53OTSrsF3xKdHuP5x
HBpyOvDIy+2Wdq8O0RMgPc6ORXV35LYQ7JDc9vWd9U9Ic/sOQI592fSH+ENwBRUV
V1L5ZqVVxg2CvQuK/sd5kA6JdhDJOPXoQq3M02El0WmgjqVSeFVOKx1vpwGi3xtV
Hj9aIxjq6XYlpHtwMil9V+hNELXk7r+OhKFYS1Nb5WHJJx50afCEG3v4E9dbXBF2
Xq1kzdfNTPIYmGtf3j6ctovwsjJtrWful86tNNoNolO4lGj4TdZPO/FzwJ1OBljI
3di/OnPmlXB9PE8B3DxO
=qwHd
-----END PGP SIGNATURE-----

--VrAC3rOdDewjQiMp5TqwgniDd1UPQ4KMK--
