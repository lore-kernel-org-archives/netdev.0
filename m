From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH RESEND 3/5] can: flexcan: adopt pinctrl support
Date: Mon, 07 May 2012 10:29:42 +0200
Message-ID: <4FA787F6.4060405@pengutronix.de>
References: <1336352040-28447-1-git-send-email-shawn.guo@linaro.org> <1336352040-28447-4-git-send-email-shawn.guo@linaro.org> <4FA78298.4080401@pengutronix.de> <CAAQ0ZWSzrfFm+=m+s8S3FDG5k_OrULN58VUVCBE=fwU0r=ZD+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig45339D8347CF5F5950D838AF"
Cc: linux-arm-kernel@lists.infradead.org,
	Arnd Bergmann <arnd@arndb.de>, Olof Johansson <olof@lixom.net>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Dong Aisheng <dong.aisheng@linaro.org>,
	linux-can@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Shawn Guo <shawn.guo@linaro.org>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <CAAQ0ZWSzrfFm+=m+s8S3FDG5k_OrULN58VUVCBE=fwU0r=ZD+g@mail.gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig45339D8347CF5F5950D838AF
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 05/07/2012 10:17 AM, Shawn Guo wrote:
> On 7 May 2012 16:06, Marc Kleine-Budde <mkl@pengutronix.de> wrote:
>> It doesn't compile yet against net-next/master, which is based on v3.4=
-rc4:
>>
>> /home/frogger/pengutronix/socketcan/linux/drivers/net/can/flexcan.c: I=
n
>> function 'flexcan_probe':
>> /home/frogger/pengutronix/socketcan/linux/drivers/net/can/flexcan.c:93=
7:
>> error: implicit declaration of function 'devm_pinctrl_get_select_defau=
lt'
>> /home/frogger/pengutronix/socketcan/linux/drivers/net/can/flexcan.c:93=
7:
>> warning: assignment makes pointer from integer without a cast
>>
>> Which tree does this series depend on? If this should go over the
>> linux-can tree, I have to ask David first to merge this.
>>
> Thanks for the response, Marc.  The patch depends on pinctrl tree and
> a couple of other patches that will go through arm-soc tree, so I
> would like to ask for your ack to have the patch go over arm-soc tree.

Fine with me. David, is this okay? Shawn, better wait for David's okay.

Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>

regards, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig45339D8347CF5F5950D838AF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk+nh/sACgkQjTAFq1RaXHMSzgCeLDzIHq+KXQ6YC52ibaUXk48Q
Mp8AmwaEzwjwYnc4F2cGlgEzSIR+E0wW
=kUl+
-----END PGP SIGNATURE-----

--------------enig45339D8347CF5F5950D838AF--
