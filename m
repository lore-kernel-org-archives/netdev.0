From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: 2.6.29-rc8: Reported regressions from 2.6.28
Date: Thu, 19 Mar 2009 10:38:54 +0100
Message-ID: <1237455534.5100.56.camel@johannes.local>
References: <MiincthRUSI.A.eKC.F4BvJB@chimera>
	 <b6a2187b0903141958u9dae0fdk1f44b387108b99e4@mail.gmail.com>
	 <b6a2187b0903142006u546fad9eme66f9ea7b464b81f@mail.gmail.com>
	 <1237140665.24621.2.camel@johannes.local>
	 <alpine.LFD.2.00.0903151136310.3131@localhost.localdomain>
	 <1237143683.24621.7.camel@johannes.local> <20090315202603.GA9077@elte.hu>
	 <b6a2187b0903160624gb9d207dv301506e589d93ed4@mail.gmail.com>
	 <1237317742.31814.28.camel@johannes.local>
	 <b6a2187b0903181958ke11abe7tdcbc4efeb950954d@mail.gmail.com>
	 <b6a2187b0903182149x77e416ecuf73be2970173c601@mail.gmail.com>
	 (sfid-20090319_054932_507952_529F646E)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-vUXLo/iHZKDZb9ENFFhy"
Cc: Ingo Molnar <mingo@elte.hu>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Adrian Bunk <bunk@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>
To: Jeff Chua <jeff.chua.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:44835 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752493AbZCSJkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 05:40:43 -0400
In-Reply-To: <b6a2187b0903182149x77e416ecuf73be2970173c601@mail.gmail.com> (sfid-20090319_054932_507952_529F646E)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-vUXLo/iHZKDZb9ENFFhy
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2009-03-19 at 12:49 +0800, Jeff Chua wrote:

> Ignore the above loop thing. The cause seems to be this one instead.
>=20
>=20
> # this needs patch to work ...
> iwconfig wlan0 mode Managed
> ifconfig wlan0 up
> iwconfig wlan0 essid xxx
> iwconfig wlan0 key restricted xxx
> iwconfig wlan0 ap auto channel auto

If you swap the key and essid lines, it will probably always work. But
I've yet to analyse your data to see why it doesn't in the other case.

johannes

--=-vUXLo/iHZKDZb9ENFFhy
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJwhKrAAoJEKVg1VMiehFYNe8P+QFY0/JCRLPUMmHya4YejR7r
1dTiQ1eOKajY2rcyrwcdP8FrXdBCOMBICRFNHb6Q3VFf1VIsqtUwrmeUs183KIRE
Eip325lKXBroPED4aqELdbHvjzD3gvsXLeHN4I5MzkZz7FVZjp5HD0XVZWHMkagv
RH+n/sf6y7JyrZHua8PjOXIoeFGdZKju8uwT093LvsVTo5GPN74hEzaqU7NVbtGY
CqWlngSpt1syB1+dE7ROMolHESjuNQ3YCEMMLHhiqXDruYUhc0xD3/qCt4tFbZpY
p8Mkx7bewgUzzFDoR7Xoa+hXYjTwwwIxNbZShyIQVvdtQoSjiZXrdrzGVRC2XW3d
rSsy4/yAJp3VJdPI1Y4fxJ2WoKp13NNRomccaFU2NqzAZfByccwPs6WAQeFLSVph
SFBdswXNECd6McxaLoIGsjD/xwQExa7aDu53XfP8G0jIKS/o8VfytTW1Rll0knf7
BPzV/CzNfDtw3hmtTm5iAtM6PNG/nyB9MdvZ6xQyvPsN0kUt8aBVuQSfv7OY4nzr
0ayGNmE3eDnKzcylP2mqakAPpkb+k6NPnBsZ9YMtjcBAvKIW3nlHZNj9vxCLr6s5
j1tvcIHQbZFgS4VZiMc1zUACs9dVZV1EFN7PIX11agQEkTcTLOjJf3ii5Q7753EG
taJIxppYfhR4cj7KXOW0
=2g5X
-----END PGP SIGNATURE-----

--=-vUXLo/iHZKDZb9ENFFhy--

