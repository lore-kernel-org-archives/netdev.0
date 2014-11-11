From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: question about ethtool bits?
Date: Tue, 11 Nov 2014 18:12:49 +0000
Message-ID: <1415729569.3398.104.camel@decadent.org.uk>
References: <20141110124718.00004efc@unknown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Y4g2GusJkXbS1M6ap1vj"
Cc: netdev@vger.kernel.org
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:34752 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751451AbaKKSNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 13:13:08 -0500
In-Reply-To: <20141110124718.00004efc@unknown>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Y4g2GusJkXbS1M6ap1vj
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-11-10 at 12:47 -0800, Jesse Brandeburg wrote:
> Ben et al,
>=20
> So, I was just looking at adding some more types/speeds to
> ethtool.h and noticed we are about out of bits in ecmd->advertising
> (and others), which are declared u32.
>=20
> We currently have room for one more type (bit 31) and then all 32 bits
> will be full.

Right, I've been seeing this coming for a while.

[...]
> There are two u32's reserved at the end of ethtool_cmd.
>=20
> Suggestions?

Any extension needs to be applied to all of advertising, supported and
lp_advertising.  So we could take 6 of the 8 reserved bytes and extend
them all by 16 bits.

Whoever does this should add getter/setter functions, as has been done
with the extension of speed.

Ben.

--=20
Ben Hutchings
Experience is directly proportional to the value of equipment destroyed.
                                                         - Carolyn Scheppne=
r

--=-Y4g2GusJkXbS1M6ap1vj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVGJRq+e/yOyVhhEJAQq0+Q//Y44CeygTxckDhigRdGtSjgrq0bqHMS6X
K3/x4rw58Dn27VgpWxyBE2bqb/uIqM+2756xkP7AVpF3xCesAYCP2lunT9ccQSdr
R6Br4Q+r4/jQF8cdoUeSpitGww3bh0UImz4QflY8yVn0oh4RM/WhXOiFgs1TN/2F
I7Gx/pvxoi9PsVpJGv3o9gyssXamEabfTSlgYCnM0W/Q6/obyiDXp7+uD09aYL9z
ti/O+XOF7vOmiKbQjnlgzL3kyryifuxn/ivjq7cb1crjMz0EvauULvXMTUm6WJg7
wklrt87aR+PZDk0sbL2HTTxoNsSR/mJi/BCxtk2LSEPUW53CyWcwb2LW+StJ7eOz
SGH49iXbXtJiug0c4ZjzJvmH4+vedWbKxWctRzhLqSGpZcaP3qKmJR5i1Dfvv7CW
ho983uA9Q7S/fINLlub3VtQjgMu3db2PiftVdGk5yksx0tytbzTbDxL2rQSnFLhj
uGSz67WdAC4NRYif9luFRSPvR8anJLRBqi8bvIB4FdyKXzOkDNl542dIMD9EgJvC
H3jj0f7LD4Y4wJRtEKsDpTq9jHcJZfj3KMafest3jJIVbSeyBSNfJjxHyWqCPxmi
dsyVvEg41lDUos6nRqwzEldeT240N3PFhCPaWqR/J++YieEE7HMEkRDAHU8xVkAg
VyDYDhXEAvo=
=vS+z
-----END PGP SIGNATURE-----

--=-Y4g2GusJkXbS1M6ap1vj--
