From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 02/16] i40e/i40evf: Rewrite logic for 8 descriptor
 per packet check
Date: Tue, 29 Mar 2016 22:29:24 -0700
Message-ID: <1459315764.2953.83.camel@intel.com>
References: <1455875651-21696-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1455875651-21696-3-git-send-email-jeffrey.t.kirsher@intel.com>
	 <CAEuXFEwPdnh8LNMXRP6fnasXO3P-iW-k1qPciXqayY+7c6=b0w@mail.gmail.com>
	 <CAEuXFEwdc1VZ6bcnMy1sqFvm=tr3zDwauW6oW8WO77F9oeERcA@mail.gmail.com>
	 <CAKgT0Uf8_Eb0G+k6N4vz69HefM3_oCkj7PB30z3keBCR4HAUnQ@mail.gmail.com>
	 <CAKgT0Udt1b8RYdh4Ex+34i+V4dRZWUuYWM=MpJK_DhuqGecjZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-og4vycClpNtz0fw1RGYd"
Cc: Dave Miller <davem@davemloft.net>,
	Alexander Duyck <aduyck@mirantis.com>,
	NetDEV list <netdev@vger.kernel.org>,
	Neil Horman <nhorman@redhat.com>, sassmann@redhat.com,
	John Greene <jogreene@redhat.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Alexander Duyck <alexander.duyck@gmail.com>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:15787 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751235AbcC3F3e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Mar 2016 01:29:34 -0400
In-Reply-To: <CAKgT0Udt1b8RYdh4Ex+34i+V4dRZWUuYWM=MpJK_DhuqGecjZQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-og4vycClpNtz0fw1RGYd
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-03-29 at 22:19 -0700, Alexander Duyck wrote:
> Minor correction here.=C2=A0 This is 72 hex, which is 114 in decimal.=C2=
=A0 The
> interesting bit I believe is the fact that we have both header and
> payload data in the same descriptor.
>=20
> You should probably check with your hardware team on this but I have
> a
> working theory on the issue.=C2=A0 I'm thinking that because both header
> and payload are coming out of the same descriptor this must count as
> 2
> descriptors and not 1 when we compute the usage for the first
> descriptor.=C2=A0 As such I do probably need to start testing at frag 0
> because the first payload can actually come out of the header region
> if the first descriptor includes both payload and data.
>=20
> I'll try to submit a patch for it tonight.=C2=A0 If you can test it
> tomorrow I would appreciate it.=C2=A0 Otherwise I will try setting up an
> environment to try and reproduce the issue tomorrow.

If you get it submitted tonight, I can have it ready in my tree for
testing for Jesse and the team when they get into the office tomorrow.
--=-og4vycClpNtz0fw1RGYd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJW+2Q0AAoJEOVv75VaS+3OVVQQAJ7PzNpc/zHPtpEFIo+PxsBG
HDbK1uuPskbPUHuMZd3qD+gVmEnL7oyxhztfxJNwNQke8mSk2Keee/4p73Kcpink
hDegrX/09zWL6hdKEU1kn6Tro915SaZ6DJEnCxZd+0heoODsFHEcjQURYpq9KUeb
5bPFEFUR66fm5ZopB+BXRQ5bIyNTpghkDG+y8UiKKoAa9eqfzs3E+WeqK0ekV6of
NEn1L9Qp15pKuVSaTPp51h4CB5y9SUuGZaRfGKvD8Y3U3+Romx2TgaMQFUWSpAO3
5rWN0+zrmLONouF9VJJ631IPr2KZUIbgt+DiCFSjn2r7Vz9UAPl9/Md+YR2WPXhF
AmhAregDU2soMxhVNf6f4m0SgOza/jKrHxNGAXk3/w4V343z168IRcM63eW7yPFi
Y2NwTyYmtvrE9iefkibSE6eJHZv+EsE2wz6Y7DApCH8a4UabAIVMbX7UOnkH4A46
OwVd3NhbXVQTvUcTWipQQLWVXTZi8WVIZfGNRsoinzm/Rns0BX1QU7Yw/bcnzeAG
PuCoGWygbuJN4KbFLIWLlRtqn54fxNLilfBPnDB62Q7oe+qt2zHNaNnsrZ0UPT7y
yD/AWLiQeBpxPLhpkXRvjIxMTb8U9y5wZ8M3rNph5df31Q4T0MBbz/pTqOQwkWqG
NHY6KVn90+b8w78V6oNS
=eBRP
-----END PGP SIGNATURE-----

--=-og4vycClpNtz0fw1RGYd--
