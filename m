From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 32/39]: mac80211: Reimplement WME using
	->select_queue().
Date: Thu, 03 Jul 2008 14:12:58 +0200
Message-ID: <1215087178.9975.6.camel@johannes.berg>
References: <20080703.000521.13130101.davem@davemloft.net>
	 <1ba2fa240807030427x19a2ea4fn50be1d2dbd587248@mail.gmail.com>
	 (sfid-20080703_135524_229112_2995C829)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-JalESuTI1pO+lH2pfHZG"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	vinay@linux.vnet.ibm.com, krkumar2@in.ibm.com, mchan@broadcom.com,
	Matheos.Worku@sun.com, linux-wireless@vger.kernel.org
To: Tomas Winkler <tomasw@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:35662 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754145AbYGCMP0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 08:15:26 -0400
In-Reply-To: <1ba2fa240807030427x19a2ea4fn50be1d2dbd587248@mail.gmail.com> (sfid-20080703_135524_229112_2995C829)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-JalESuTI1pO+lH2pfHZG
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2008-07-03 at 14:27 +0300, Tomas Winkler wrote:
> On Thu, Jul 3, 2008 at 10:05 AM, David Miller <davem@davemloft.net> wrote=
:
> >
> > Unfortunately it temporarily loses some features, such
> > as packet dropping (easy to add) and requeueing (harder).
>=20
> Requeueing is must. This effectively kills HT. We must be able to
> requeu packets from the legacy queue into apmdu queue.

I think the other direction is much more important (and also far
easier), and you could help put it back :)

Right now though, it still just hangs.

johannes

--=-JalESuTI1pO+lH2pfHZG
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJIbMJGAAoJEKVg1VMiehFYpyUQAIMdRlhSm56u1lCLp6ppugTN
uVP7TkdwhejBDBSS//2Crn0AIABY4QolEdgtVxA08u0vi+0+SJRZLXX3thsaWjcn
+GdaboY8RJzrwKvVTVP2TyAZoR6LBbewCXPLWyX9NmV7SwrBwckykRaGvKUEY+3p
Ai7p528jxVZav/RP2h/K36C33wHC3dOCTINh3kMgesBR9USmIdnodSuVgiVwQhpn
HzL5h1BS1fXrGDSY41FdNUVAwUtRsYFd/SbWf5sgjKrEvza7syaIXqwb/Oc+3w7g
OUQfYCdcOlG12Rd4gVRQBEduFg4UP8bVwqhPBcImRety4l6DhK7scXERpYZA9xJp
MvS+SHcRDHWExYJ1l5Dg8NLeI6+CciK2llcbux/s/lSRjBG1wf1ZW4baFq0AR0+U
KWVBmWOphDnZGoMs3we0QVNCG/NmUPwaCThCvHreE+3+XTdzaP/Li6IFP+qAWRGF
pFKgyGFqOF1iD2GiUHghFB53P2zXLHZScHezwxKz/gjHOEvGSWh1ri192UfbsgKP
y2ZY6FdLYYtW4mct/EKuFB5wOi4gfNuqAbo24pA0En91mxQSYPF+lF8ssqi0th0l
niWrpwvwMKTQjxsC2p08mWXLAWcT6xinhVN9spoLu7RzX+eQFeM7j5cizvyddZBX
BYwVHkqZb3ux13G7kW8/
=nBxx
-----END PGP SIGNATURE-----

--=-JalESuTI1pO+lH2pfHZG--

