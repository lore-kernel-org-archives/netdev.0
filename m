From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: Fw: [Bug 84061] New: net/batman-adv/gateway_client.c:813: missing
 sanity check and dodgy coding ?
Date: Tue, 09 Sep 2014 17:02:52 +0200
Message-ID: <540F169C.8030700@meshcoding.com>
References: <20140908173014.2946e411@uryu.home.lan>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="15qQmPbkb6iCqXq6e1OXasxOCoWCcMtqs"
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>,
	The list for a Better Approach To Mobile Ad-hoc
	 Networking <b.a.t.m.a.n@lists.open-mesh.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:39720 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752836AbaIIPEQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 11:04:16 -0400
In-Reply-To: <20140908173014.2946e411@uryu.home.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--15qQmPbkb6iCqXq6e1OXasxOCoWCcMtqs
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

forwarding to the batman-adv mailing list and commenting inline.

On 09/09/14 02:30, Stephen Hemminger wrote:
>=20
>=20
> Begin forwarded message:
>=20
> Date: Mon, 8 Sep 2014 00:04:40 -0700
> From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.k=
ernel.org>
> To: "stephen@networkplumber.org" <stephen@networkplumber.org>
> Subject: [Bug 84061] New: net/batman-adv/gateway_client.c:813: missing =
sanity check and dodgy coding ?
>=20
>=20
> https://bugzilla.kernel.org/show_bug.cgi?id=3D84061
>=20
>             Bug ID: 84061
>            Summary: net/batman-adv/gateway_client.c:813: missing sanity=

>                     check and dodgy coding ?
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 3.17-rc4
>           Hardware: All
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>           Assignee: shemminger@linux-foundation.org
>           Reporter: dcb314@hotmail.com
>         Regression: No
>=20
> net/batman-adv/gateway_client.c:813:31: warning: logical not is only ap=
plied to
> the left hand side of comparison [-Wlogical-not-parentheses]
>=20
>     gw_node =3D batadv_gw_node_get(bat_priv, orig_dst_node);
>     if (!gw_node->bandwidth_down =3D=3D 0)
>         goto out;

I think this was meant to be:

if (!gw_node || (gw_node->bandwidth_down =3D=3D 0))

>=20
> Function batadv_gw_node_get can return NULL, so there's
> a missing sanity check there and maybe the if condition
> can be reworked for clarity.
>=20

--=20
Antonio Quartulli


--15qQmPbkb6iCqXq6e1OXasxOCoWCcMtqs
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUDxakAAoJEJgn97Bh2u9eoAIQAKjAy3dfswROF0tXt1nTkUms
wTol2EnQ7M7f8JMEEOKEKWDyxDL2v+3KAMOrBamMvdRcii79VEynMJlqpVm5tvoH
das3h2sWtolrafDKVsx1oWXVRDyZAHcpXn/OMoPxud9dOC03lwfJkWcOPkpQUIr4
v0KnBSUcKUKzZz+mA/HVozCkedpuOn7ourGe6Tj2Uzkyu85uVhmqfN+mycFhqCWF
Gtb07z+L7lzq3OqTyotycfp+Eb52mPEv9naI1cPNrf4EqzfU8Bw/+MXSonwdx0VW
jIfUaKhrtaPER+bdogebjPTlXWSG92PSprndihiXAuGE3eKJSaTCAqLcbomdcqTb
Sr2A3c01+fkn2KIxOub8lojR5xP9omBpK5yvEOAUfdkE12affjTFdW6PGMUnLJcp
ptItvXvbV3FEwpfI5PpNrapq+c6uoKssT/ktVnVYoltHAOWNJoZ3+qIWMHo95FZL
ZTy/L9Tr9nR8oEfHQf01nRN9EJ/XXuaw2Os0YzI/g58sRIO25Y1QRBrqfUkVCQvF
u/u4WmYgUu1SbcdywnhHsDEj6blm3mHAWF21ybJsPiThw20e6pSslrbOj4B9El3C
loQgTXoeEVWrjHLkNDa+hgOKt6xBjrGN5Bw+9kAO05MP+R7RiFtsSyTkVE0f07Hp
3E6FgUYo8IBQ2TrZV7Od
=+HgH
-----END PGP SIGNATURE-----

--15qQmPbkb6iCqXq6e1OXasxOCoWCcMtqs--
