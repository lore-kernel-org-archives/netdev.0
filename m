From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH] net: ethernet: cpsw: ignore VLAN ID 1
Date: Tue, 6 Jan 2015 16:04:10 -0600
Message-ID: <20150106220410.GH32308@saruman>
References: <1420566212-30081-1-git-send-email-balbi@ti.com>
 <20150106.141323.2091288413667564444.davem@davemloft.net>
 <20150106203119.GC32308@saruman>
 <20150106.165911.604916635790072318.davem@davemloft.net>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="J/zg8ciPNcraoWb6"
Cc: <balbi@ti.com>, <netdev@vger.kernel.org>,
	<linux-omap@vger.kernel.org>, <stable@vger.kernel.org>,
	<mugunthanvnm@ti.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:43168 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755469AbbAFWEp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2015 17:04:45 -0500
Content-Disposition: inline
In-Reply-To: <20150106.165911.604916635790072318.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--J/zg8ciPNcraoWb6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Tue, Jan 06, 2015 at 04:59:11PM -0500, David Miller wrote:
> From: Felipe Balbi <balbi@ti.com>
> Date: Tue, 6 Jan 2015 14:31:19 -0600
>=20
> > What you're saying here is that you prefer to drop a feature that works
> > for all other 1023 IDs because 1 ID is quirky. Sounds like overkill
> > to me.
>=20
> The other option is to software fallback only for VLAN 1.

now we're talking. Keep in mind, however, that this IP runs on mere
single-core cortex A8 and single-core cortex A9 devices which already
have somewhat of a hard-time keeping up with the non-accelerated
checksum calculations. But fair enough, if that's the way to go, it is
the way to go.

cheers

--=20
balbi

--J/zg8ciPNcraoWb6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUrFvaAAoJEIaOsuA1yqRE89YQAKFYp2ZkppYy+kgHS+afzIai
6+wjk/QcmYe5DMvOmjx7QX0amSxAD7JiejL9LrOlfvh/gGUNyl+2095PiVtSWPcT
otnU6xy1bdxbZ1pJajRYLq+qZ116hJyaaweN/ynNx41hN4LiA7atbaLa4WvV/wGc
P07rIvkzBUXfxMuW63R6CZ8YMPlU0fdvOLjsmP9WT1gmZCH1isyZGYJ91SrHSaU3
7Bpcc9NfAjEItPM54YttAH5aY1GjvgHpl4aUJA/XblZf+X1jiZ1VXOKzmBkPMSky
vAygkT3YyVwasx41WNR/OaSqLi4vc8yuohqjC9EJWEXMAM1L0qid6Ony2XQFt2s/
CqjxYpI4l9tG7Ol7Y5177sdjm3DLKbqR2+oLQjbAo4oaCPfiXEgK4uoymRvFc6qY
g1ljcFxn6xRzRPU0PGdJ0N3hdClbc2FmKLJqoDqrdgT49nr1WwFMqmEL6KCW/6/U
8Zwk8+AaIAZ7n52k2nC9vUSJGqnKkmoT9+nKJ52oWE1MpvTTpFpea3B5a2fLX7S3
xbyXXlHj9fI+yleeUGUhVSZhWJQZeC5hG7kQYgYK7AB0zRx97//D0ogrPWxdOuS/
NZvmOlu67S8tim0d+/+/VQ7dggyB6MFHPGW0SMf4Y7jYVpOR5ShMcsM4alq86TVV
O3wb8dZ15IoYZ2w4b8mU
=+r1f
-----END PGP SIGNATURE-----

--J/zg8ciPNcraoWb6--
