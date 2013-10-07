From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: dev: fix nlmsg size calculation in can_get_size()
Date: Mon, 07 Oct 2013 16:14:36 +0200
Message-ID: <5252C1CC.4060809@pengutronix.de>
References: <1381001117-19624-1-git-send-email-mkl@pengutronix.de> <52507B7D.6030008@grandegger.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="2PMDIRFSeliR7BfH5pe3xFc4TIu9hIT6m"
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <52507B7D.6030008@grandegger.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--2PMDIRFSeliR7BfH5pe3xFc4TIu9hIT6m
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 10/05/2013 10:50 PM, Wolfgang Grandegger wrote:
> On 10/05/2013 09:25 PM, Marc Kleine-Budde wrote:
>> This patch fixes the calculation of the nlmsg size, by adding the miss=
ing
>> nla_total_size().
>>
>> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
>> ---
>> Hello,
>>
>> this patch touches the rtnl_link_ops get_size() callback:
>>
>>     static struct rtnl_link_ops can_link_ops __read_mostly =3D {
>>     ...
>>     	.get_size	=3D can_get_size,
>>     ...
>>     };
>>
>> By looking at other nlmsg size calculation I think a nla_total_size() =
for all
>> contributers is needed. Am I correct?
>=20
> Yes, seems so, nla_put() calls this code:
>=20
>   http://lxr.free-electrons.com/source/lib/nlattr.c#L328

Is this an Acked-by? :)

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--2PMDIRFSeliR7BfH5pe3xFc4TIu9hIT6m
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlJSwcwACgkQjTAFq1RaXHOhcQCfcT3vmm1b/sKWmUovWENPbWwM
09EAn1YDC44rZrRfEbJXvnoYrqJp75WA
=eI9I
-----END PGP SIGNATURE-----

--2PMDIRFSeliR7BfH5pe3xFc4TIu9hIT6m--
