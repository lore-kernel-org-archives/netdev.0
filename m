From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: monitor_during_oper on rt*pci (or any other pcmcia card)?
Date: Thu, 1 Jun 2006 19:58:41 +0200
Message-ID: <200606011958.45376.IvDoorn@gmail.com>
References: <1149162449.8877.72.camel@johannes>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1777316.10Dc1xYTef";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, rt2x00-devel@lfcorreia.dyndns.org,
	Jean Tourrilhes <jt@hpl.hp.com>, Florian.Rampp@web.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:11684 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S965226AbWFARzz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Jun 2006 13:55:55 -0400
Received: by nf-out-0910.google.com with SMTP id c31so744752nfb
        for <netdev@vger.kernel.org>; Thu, 01 Jun 2006 10:55:53 -0700 (PDT)
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1149162449.8877.72.camel@johannes>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1777316.10Dc1xYTef
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi,

> Florian approached me with a project where you need a pcmcia card that
> can have monitor_during_oper. I'd use bcm43xx but unfortunately the
> signal strength calculations are way off right now, and that's another
> requirement.
>=20
> Can the rt family of cards be made to support this with reliable signal
> strength readings?

At this moment the rt2x00 drivers are not known for their correct signal
strength reporting. The reading is coming out of the registers but
it isn't working in all cases.
Even the legacy drivers from Ralink self are not known for their correct
behaviour but some issues around that have been traced to bugs in the
driver. But it could be possible the registers are wrong as well.

> Or maybe I should rephrase the questions: which pcmcia cards can support
> this in their hardware? I might be willing to port their drivers over to
> d80211 just to get some more familiarity with the stack...
>=20
> Now, if no one can point me to ones that do have working signal
> strength, I'll probably have to do more reverse engineering on bcm43xx
> to get some reliable readings :/
>=20
> Thanks,
> johannes
>=20

--nextPart1777316.10Dc1xYTef
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEfyrVaqndE37Em0gRAul7AKDfVqwkxfOspJpmAwjJPyTScqee1ACghoQp
1QwZt957FoibtzIa2nsOkdQ=
=r+3h
-----END PGP SIGNATURE-----

--nextPart1777316.10Dc1xYTef--
