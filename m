From: Michael Buesch <mbuesch-KuiJ5kEpwI6ELgA04lAiVw@public.gmane.org>
Subject: Re: Machine hard lock
Date: Thu, 22 Dec 2005 19:05:56 +0100
Message-ID: <200512221905.56663.mbuesch@freenet.de>
References: <20051222075903.3E196429EA9@mognix.dark-green.com> <1135271149.8765.0.camel@localhost> <43AAE710.90502@mtessun.dyndns.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3446161.jr6Zn4VxLk";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-admin-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: martin.tessun-xUmxicX565+Z9vWoFJJngh2eb7JE58TQ@public.gmane.org
In-Reply-To: <43AAE710.90502-xUmxicX565+Z9vWoFJJngh2eb7JE58TQ@public.gmane.org>
Sender: bcm43xx-dev-admin-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
Errors-To: bcm43xx-dev-admin-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Subscribe: <http://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
List-Unsubscribe: <http://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.berlios.de/pipermail/bcm43xx-dev/>
List-Id: netdev.vger.kernel.org

--nextPart3446161.jr6Zn4VxLk
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Thursday 22 December 2005 18:49, Martin Tessun wrote:
> Johannes Berg wrote:
> > On Thu, 2005-12-22 at 17:51 +0100, Martin Tessun wrote:
> >=20
> >> At least you get them inserted ;) When I try to modprobe rate_control =
I=20
> >> get the following:
> >=20
> > insmod 80211 first.
> >=20
> > johannes
>=20
> No, this ist not the problem.
> When inserting 80211 I get the same message;
>=20
> kernel: 80211: ieee80211_tx_packet_data is bigger than the skb->cb (48 >=
=20
> 40)
>=20
> And *this* is the real problem. The two structs don't match somehow.

You're on a 64bit machine.
Run a 32bit kernel, or wait a few weeks until this is fixed.

=2D-=20
Greetings Michael.

--nextPart3446161.jr6Zn4VxLk
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQBDqusElb09HEdWDKgRAtmUAKCFo+9NbrfYQxpBaL4zNY9p3BB1gwCeP7Ch
SUaEdAhgiyo1jAU5Q32AAJE=
=ju5O
-----END PGP SIGNATURE-----

--nextPart3446161.jr6Zn4VxLk--
