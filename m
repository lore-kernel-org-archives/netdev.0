From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [net] BUG: unable to handle kernel NULL pointer dereference at
 000000000000022f
Date: Tue, 13 May 2014 09:51:58 +0200
Message-ID: <5371CF1E.8090903@pengutronix.de>
References: <537188D4.6050201@intel.com> <5371AA32.6070407@hartkopp.net> <5371CD3A.9020500@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="0oJNWNKvum3OuhJMmlIcnicfDPNj3I9gq"
Cc: Fengguang Wu <fengguang.wu@intel.com>,
	linux-crypto@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, linux-can@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>,
	Jet Chen <jet.chen@intel.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <5371CD3A.9020500@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--0oJNWNKvum3OuhJMmlIcnicfDPNj3I9gq
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 05/13/2014 09:43 AM, Marc Kleine-Budde wrote:
> On 05/13/2014 07:14 AM, Oliver Hartkopp wrote:
>> Hello Jet,
>>
>> this is likely not CAN related, as
>>
>> # CONFIG_CAN is not set
>>
>> and all the CAN changes introduced by Marc's merge are not even compil=
ed in
>> your setup.
>>
>> So I assume the issue somewhere in the netlink or ipv6 stuff (see comm=
it at
>> the end.
>=20
> Yes, I my merge is probably broken. That was an attempt to merge net
> into net-next, but I'm going to ask David Miller to do so. As I'm going=

> to rebase this branch onto David's net-next (after the net merge), we
> can ignore this for now.

While I was asleep David merged net to net-master ;) I just rebased this
branch and updated it. The oops should be gone now.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--0oJNWNKvum3OuhJMmlIcnicfDPNj3I9gq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlNxzx4ACgkQjTAFq1RaXHPcPQCgmCNTHEPQSYNlBdr0GuJLbZm6
T8MAoIGfXp5A5Fva6d38QFfdIDuzb7Y3
=NgTP
-----END PGP SIGNATURE-----

--0oJNWNKvum3OuhJMmlIcnicfDPNj3I9gq--
