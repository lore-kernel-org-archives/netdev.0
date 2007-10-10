From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH][NETNS] Make ifindex generation per-namespace
Date: Wed, 10 Oct 2007 20:34:03 +0200
Message-ID: <1192041243.4770.8.camel@johannes.berg>
References: <470B71CD.3000706@openvz.org>
	 <m1przoxk1v.fsf@ebiederm.dsl.xmission.com>
	 (sfid-20071009_184201_919062_823395B5)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-Cl76jkhA4+qS38QFISM2"
Cc: Pavel Emelyanov <xemul@openvz.org>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:60110 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752400AbXJJSeG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 14:34:06 -0400
In-Reply-To: <m1przoxk1v.fsf@ebiederm.dsl.xmission.com> (sfid-20071009_184201_919062_823395B5)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Cl76jkhA4+qS38QFISM2
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-10-09 at 11:41 -0600, Eric W. Biederman wrote:

> So please hold off on this until the kernel has been audited and
> we have removed all of the uses of ifindex that assume ifindex is
> global, that we can find.

I certainly have this assumption in the wireless code (cfg80211). How
would I go about removing it? Are netlink sockets per-namespace so I can
use the namespace of the netlink socket to look up a netdev?

johannes

--=-Cl76jkhA4+qS38QFISM2
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUARw0bGqVg1VMiehFYAQJNpg/+P8u4WgRdYpif8XycMv1WPSzWzJ1mvfsO
PvmKpxda2dvnTLFt9pXfYgnTTCpJE4An7mc2A3GHI8KMfRsvmvRMTC8OObT9Pja7
+fbD7ktkKtDIjRjinpIRxpbhdBeZi25P7OStxz8MqI3fBx7SvzOm9Hf6yDKY3POM
8WXvDJCFr9llVE3712DDCthxD724F4pGJ/mbnsbjMVWMrtpJh/Evjylm+xlmn9Vb
z9beyTwqlD+jTsUQVGs1/TVCU9GT0ZuBwfUxCVSiNXlqKbTHmEUE/+KaFA4Xavwr
C47+l7DSMs7uNHKdTYgfaBvvYbQhiQwGvMKj82pZ9V1Z5sx+39KBACB8C1u6BQ67
PoZLoBVXeXEVMK13YoWcxIW1tBxgb6M4LhhFotSEWvLZGXq4A1Y05lUawAm+qCAK
ZlpBZyzKaDyloDD8yYe4Ba3FZi0Nb9RtsSjaiy9gPyVao5ei1rd2Gk4jIy9C82RQ
08ou4HfjEa5I3hqsiYWwpgO+jtvKj98d0/4oph3fBnnz9s9yiCfDeUvknAy0k2El
/K0KP4xuVf21B8AEq56SuFOg//m6PF9bTeHkvvt686VbHHpEIbneZTe5GSubSbHg
hvS6wAfQbY84GtMeSggggYMUI1UMtXrdUPsahHkCQFvPowmpBNRF+cj5D0DtsinW
G1iR9mh95zk=
=Ulfb
-----END PGP SIGNATURE-----

--=-Cl76jkhA4+qS38QFISM2--

