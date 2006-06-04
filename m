From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [RFC PATCH 1/2] Hardware button support for Wireless cards: radiobtn
Date: Sun, 4 Jun 2006 10:02:29 +0200
Message-ID: <200606041002.33696.IvDoorn@gmail.com>
References: <200605251716.00742.IvDoorn@gmail.com> <200606021630.34544.IvDoorn@gmail.com> <200606031045.08763.stefan@loplof.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1940879.2k0yvYH2KY";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	rt2400-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:22478 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932143AbWFDH7a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Jun 2006 03:59:30 -0400
Received: by nf-out-0910.google.com with SMTP id c31so1608323nfb
        for <netdev@vger.kernel.org>; Sun, 04 Jun 2006 00:59:29 -0700 (PDT)
To: Stefan Rompf <stefan@loplof.de>
In-Reply-To: <200606031045.08763.stefan@loplof.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1940879.2k0yvYH2KY
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Saturday 3 June 2006 10:45, Stefan Rompf wrote:
> Am Freitag 02 Juni 2006 16:30 schrieb Ivo van Doorn:
>=20
> > > Or actually, I don't think the radiobtn/ won't be actually needed as
> > > prefix. The name passed to the radiobtn driver by the driver should be
> > > sufficient.
> >
> > Updated version,
> >
> > Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>
>=20
> I don't like the patch in it's current form. Many notebooks have a number=
 of=20
> additional keys that need to be queried/polled using the same interface, =
but=20
> just one button is to control the radio, the rest are multimedia keys tha=
t=20
> just need to be forwarded to userspace. Or maybe a bluetooth key.

Except for the bluetooth radio key (which should be supported by the radiob=
tn interface as well)
the other buttons have support through already excisting input devices if I=
 am correct.
This radiobtn driver is there to poll the device frequently about the radio=
 state only
since that is one of the few buttons that is not sending anything to usersp=
ace at the moment.

Ivo

--nextPart1940879.2k0yvYH2KY
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEgpOZaqndE37Em0gRAmjGAKCpHHWC6evyX27DiKjvzYjq9PPglACbB2IS
NbxUpjLDVdVo9rwP2NyD1qg=
=bTtV
-----END PGP SIGNATURE-----

--nextPart1940879.2k0yvYH2KY--
