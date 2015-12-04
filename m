From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [BUG] net: performance regression on ixgbe (Intel 82599EB
 10-Gigabit NIC)
Date: Fri, 4 Dec 2015 21:31:58 +0000
Message-ID: <B1166ACF-986A-418C-953F-9B5F68D44C36@intel.com>
References: <20151203162627.GA8989@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_0C8A8527-1F54-43AE-9E85-7C17D5E5F5B6";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Jirka Hladky <jhladky@redhat.com>,
	"Adam Okuliar" <aokuliar@redhat.com>,
	Kamil Kolakowski <kkolakow@redhat.com>
To: Otto Sabart <osabart@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:7923 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754837AbbLDVc1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Dec 2015 16:32:27 -0500
In-Reply-To: <20151203162627.GA8989@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_0C8A8527-1F54-43AE-9E85-7C17D5E5F5B6
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

Otto Sabart <osabart@redhat.com> wrote:

> I probably found a performance regression on ixgbe (Intel 82599EB
> 10-Gigabit NIC) on v4.4-rc3. I am able to see this problem since
> v4.4-rc1.
>=20
> The bug report you can find here [0].
>=20
> Can somebody take a look at it?
>=20
> [0] https://bugzilla.redhat.com/show_bug.cgi?id=3D1288124

A recent patch has disabled LRO by default because it is incompatible =
with forwarding. If you aren't interested in forwarding, you might try =
enabling lro with ethtool.

--
Mark Rustad, Networking Division, Intel Corporation

--Apple-Mail=_0C8A8527-1F54-43AE-9E85-7C17D5E5F5B6
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJWYgZNAAoJEDwO/+eO4+5uhfcP/jihOfAYki2HszzOO7q0pZBB
i52/iDWd2ZCXWGopyo5/goT95eA/mdxhS0u3dHFDWVCCBcl87k7EYW6PHT8Eurrb
pT/DjPQN5PRjJ98ZcRPG37WSya13jrqb87etPMa4CDrzMX7zBvEETkFbVJYeW2gQ
sDGMmNP8emVnWDPi82GoA/z8iVjqEecHuzSs6WgUw9OrdKwDd+guSP4Oa1GKE95c
BDu5IypU8NMeZfuQD9PMMMuMhfql9d1KOhh/tcBIKDUvhEnazh2nLdpzX1Tjn5IP
xaRkxzlnokvieao4ykAzGwUdooqk6BTR3dyynuZFF2TzXjyHXqbiCGeAAQgNgTAM
gGU0ne5DZ++EAoXFyDyLW9U0W9kqB5E5YFKhmkO0/R20IdTvTH/3T5g3SVjTBQpp
uEMbFuhvs1wyn+qn2oqs4/tWi/UYsTUVwklYuKJP/Ms7w44Wg2PIrFhT9D7/UKys
LAnH4FBjcyIkhaC+iKVdSHObMf2IKLsM+h0a1iiwm6eVIUiQVRnVf0iFiO7eXusT
TTZl7cK4kkmZ37VWN9na+Xv6jcvdHpAYPTIX0ZyEc68FZRlZxrgh714608GyNhTS
RF/A9YfUqpC3yPvT8pSLas3Y1IFFnrNMUZFT24KTwdb6GnCXnm156C6aAqHBUpGo
oTb0TcRC7MKsmZ/+Jqt9
=KVCL
-----END PGP SIGNATURE-----

--Apple-Mail=_0C8A8527-1F54-43AE-9E85-7C17D5E5F5B6--
