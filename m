From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: Occational lockups during boot with post 2.6.22 kernels
Date: Wed, 18 Jul 2007 17:51:10 +0200
Message-ID: <1184773870.4002.8.camel@johannes.berg>
References: <m3sl7mk1f1.fsf@telia.com>  <469E2AAB.2010408@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0481363156=="
Cc: Peter Osterlund <petero2-zq6IREYz3ykAvxtiuMwx3w@public.gmane.org>, Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
To: Chuck Ebbert <cebbert-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <469E2AAB.2010408-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org


--===============0481363156==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-cFIavx7nPsrz2d1k/Gh7"


--=-cFIavx7nPsrz2d1k/Gh7
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-07-18 at 10:58 -0400, Chuck Ebbert wrote:
> On 07/17/2007 08:20 PM, Peter Osterlund wrote:
> > Current -git kernels sometimes lock up on my computer during boot. I
> > guess it happens about 10-20% of the time. I first saw this maybe a
> > week ago, but never with kernels <=3D 2.6.22.
> >=20
> > The last reported info on the console is that named is started.
> > SysRq-T still works and reports the non-sleeping tasks below.
> >=20
> > My guess is that wpa_supplicant and events/0 deadlock and later the
> > named thread also hangs when it needs a deadlocked resource.
> >=20
> > I'm using the bcm43xx driver.
> > =20
> > No lockdep errors are reported before the lockup. Earlier during boot
> > the kernel reports:
> >=20
> >   Good, all 218 testcases passed! |
>=20
> Try this, it should at least detect the problem:
>=20
> http://lkml.org/lkml/2007/7/17/202
> http://lkml.org/lkml/2007/7/17/204
> http://lkml.org/lkml/2007/7/17/203
>=20
> It's a known bug in wireless/80211, not sure when it will be fixed.

Heh, yes, that's the patchset that came from this bug :)
A patch for this is available but due to process issues hasn't
percolated up yet. See
http://thread.gmane.org/gmane.linux.kernel.wireless.general/3315/focus=3D33=
19

johannes

--=-cFIavx7nPsrz2d1k/Gh7
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGnjbu/ETPhpq3jKURAkewAJ4upZrVdlFmk1Iu8lkl57u4JWVe9wCaA1Ja
LtdjTGABatX+Da4zjdqWh40=
=e7Hh
-----END PGP SIGNATURE-----

--=-cFIavx7nPsrz2d1k/Gh7--


--===============0481363156==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Bcm43xx-dev mailing list
Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/bcm43xx-dev

--===============0481363156==--
