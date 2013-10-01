From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 0/9][pull request] Intel Wired LAN Driver Updates
Date: Tue, 01 Oct 2013 15:15:57 -0700
Message-ID: <1380665757.2075.0.camel@jtkirshe-mobl>
References: <1380627236-3190-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20131001.125116.1237920409152830224.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-mmdTQv74my91nhnnypi6"
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:34512 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751877Ab3JAWQV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Oct 2013 18:16:21 -0400
In-Reply-To: <20131001.125116.1237920409152830224.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-mmdTQv74my91nhnnypi6
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2013-10-01 at 12:51 -0400, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Tue,  1 Oct 2013 04:33:47 -0700
>=20
> > This series contains updates to ixgbevf, ixgbe and igb.
> >=20
> > Don provides 3 patches for ixgbevf where he cleans up a redundant
> > read mailbox failure check, adds a new function to wait for receive
> > queues to be disabled before disabling NAPI, and move the API
> > negotiation so that it occurs in the reset path.  This will allow
> > the PF to be informed of the API version earlier.
> >=20
> > Jacob provides a ixgbevf and ixgbe patch.  His ixgbevf patch removes
> > the use of hw_dbg when the ixgbe_get_regs function is called in ethtool=
.
> > The ixgbe patch renames the LL_EXTENDED_STATS and some of the functions
> > required to implement busy polling in order to remove the marketing
> > "low latency" blurb which hides what the code actually does.
> >=20
> > Leonardo provides a ixgbe patch to add support for DCB registers dump
> > using ethtool for 82599 and x540 ethernet controllers.
> >=20
> > I (Jeff) provide a ixgbe patch to cleanup whitespace issues seen in a
> > code review.
> >=20
> > Todd provides for igb to add support for i354 in the ethtool offline
> > tests.
> >=20
> > Laura provides an igb patch to add the ethtool callbacks necessary to
> > configure the number of RSS queues.
>=20
> Pulled, thanks Jeff.
>=20
> Please address Ben Hutching's concerns about the state of the device
> after a number of channels configuration failure with follow-on
> changes, if necessary.
>=20
> Thanks.

Understood, will do.

--=-mmdTQv74my91nhnnypi6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAABCgAGBQJSS0mdAAoJEOVv75VaS+3O2SUQAJwI9ZZy15ekVitw3Qgfpj28
HIApSjpmYUQqt3gdXIaqkk4JOanG4Pnifcu1RB1gUqSuMGBaA9Q6+ORJ1zwk9NkW
msLOxTYENvvODkciThC7vOFkbYzhSC2FZfdlqG7ZUewOgyRFQCXbvBtNHJNkKts4
XEdsxfsHzgrr5auVZeLbA6dTHQrjd/x6vZpz0taAzMW45hzyLIORw+KFG9AGO070
rMVRft5eCi48noWZYy42Y0Kl3awboUarKCSrrBg+8j/X6ytZWptzh0q4t429TLKn
Bt9brAII6TuswWWy1uzAotZCed5QVtOD8RQmrk6BSxcnnnwHPbPBf3PKqbwYJof4
xgMEdVrHlbbZvTxwynxdL3HZRPJQbiNhbYR5j2WJ9bhCizDID3fgqrJsC8JW7QG0
wAI+nux1R4LBUd6H01iNmVsjpTY03N2kO+LlbbYNNYP/wKTsl4WSzaoMKR2cFBI4
c1yC6V3nP5RSVg9MTZDKeBRsjefGNYzvnyOlhVjGZ27D5r1GV1UG5xvsH5zZPnoL
aqMl6uNYtqyRoz4YaQ7FJpO4XQ4M+js/C7UJRaVVn1FgFTfppFdivTZ16Ogf/nEs
4pwV1dnJbQI2G5lbEhRtuXh8Asv30iswHyY8OF51nlEKw7K6PQbCcfSfU/vPESPT
01OEf/3MRGGTs38Fe1/m
=HzgH
-----END PGP SIGNATURE-----

--=-mmdTQv74my91nhnnypi6--
