From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Translation table available between 'ethtool -k' and 'ethtool
 -K' ? For Linux?
Date: Thu, 20 Nov 2014 23:32:34 +0000
Message-ID: <1416526354.7215.4.camel@decadent.org.uk>
References: <BABF60987D48764FA4071AC73CB9C56162EBFBD0AC@AUSX7MCPC101.AMER.DELL.COM>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-3Sj95Bf4Bol0H2VQ5AhJ"
Cc: netdev@vger.kernel.org
To: Spike_White@Dell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:33141 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756794AbaKTXcs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2014 18:32:48 -0500
In-Reply-To: <BABF60987D48764FA4071AC73CB9C56162EBFBD0AC@AUSX7MCPC101.AMER.DELL.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-3Sj95Bf4Bol0H2VQ5AhJ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-11-20 at 15:10 -0600, Spike_White@Dell.com wrote:
> Ethtool developers,
>=20
> =20
>=20
> Is there a translation table available between the offload names that
> ethtool =E2=80=93k reports and the offload names that ethool =E2=80=93K a=
ccepts?
>=20
> =20
>=20
> Our network engineering team has to standard to disable all NIC
> offloads.  I don=E2=80=99t disagree;  several have often bitten us in the
> past.  LRO on vmxnet3 vNICs, TSO on old NICs and (just now) LRO on
> ixgbe/Intel NIC.

So instead of properly validating drivers, you just assume they all have
the same bug as something you saw in the past?

You may think you're being conservative, but by using non-default
settings you're actually taking more of a risk.

> And we have CPU for days, never CPU-limited on our servers.

Lucky you.  It's a shame about the power going to waste.

> If ethtool =E2=80=93K accepted the offload format that =E2=80=93k reports=
, then
> disabling all offloads would be trivial:
[...]
> Is there a translation table somewhere that translates from the =E2=80=98=
-k=E2=80=99
> output offload names to the =E2=80=98-K=E2=80=99 style offload names?
[...]

Yes, it's the off_flag_def array.

For any newly defined features, ethtool will simply use the name
supplied by the kernel for both -k output and -K argument parsing.

Ben.

--=20
Ben Hutchings
Man invented language to satisfy his deep need to complain. - Lily Tomlin

--=-3Sj95Bf4Bol0H2VQ5AhJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVG56F+e/yOyVhhEJAQqiWQ/8D/1fNeiwFz1vnxqOK1nyYkrmWbAAFLfN
TbAl5U8dFWVIJXtu+zSAZasfqV/3DkwMnJy+Bd16sdeBnG7q8G77C03U7E7W6Akf
nxZPIjnHZiZCis2ykBAFGzbJIfrOpY14VHdPeNLZSDm4CJIUGyY/u3/N/y1wAhZK
cu9F/7tzjjP6PDPO034i+KbzohO4WMgKDid29vMjxn0amPPurJNB5ongCmj/FlOI
FL6YXzdxVGm//jxd7QiXT/gGtgdjxA6DMwlb8jPa33C7fq3si6CIWhJnYFjIdkFl
mwepjT5L6G4+2eaD1CWv3Fo6Ge+sGBCtWkbF/NGeo7zjoZLj1Rm0FtTGYFETC50z
wW7wOv2mNzO+oDa4UGDhOz+FbW94POUdPZMYGGKvxtIyCnZtnxh9FlNr7zFlSUbU
uzqsyfdeJYBoo3kwYhH16B9E+8PS1hJzza4WLEVRBLt4xcGS0rmScGUUNYPOQZBX
rBu6EFLfShkG2fH5tUFFJ8v8Twnqz8M2sobUikhx8lcTFD5P1QxE2wPWQaaglNQz
91zMnVzidAd9f5mhaIjYj5NHmA8q4bvJ8LrVGMM4kJZQiOIR3mGyQe+hDlBsOK2z
jQR81JdwiknBvfPX7h2Rk/RnPXGfIKBc2B5otnu+AWYrnWn7SdSNatIWQQFJ3ijU
vVHVqAZX4KM=
=yTV1
-----END PGP SIGNATURE-----

--=-3Sj95Bf4Bol0H2VQ5AhJ--
