From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [RFT PATCH] net: remove legacy ethtool ops
Date: Sat, 18 Jun 2011 11:19:50 -0700
Message-ID: <1308421191.22851.11.camel@jtkirshe-mobl>
References: <20110507114802.A0C841389B@rere.qmqm.pl>
	 <BANLkTikHS0=XaVb4tutWAJTYcMLgYPzTGA@mail.gmail.com>
	 <20110618171543.GA11090@rere.qmqm.pl>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-TTFxgB31u2KZR674Cyu8"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:34936 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751921Ab1FRSTv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Jun 2011 14:19:51 -0400
In-Reply-To: <20110618171543.GA11090@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-TTFxgB31u2KZR674Cyu8
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2011-06-18 at 10:15 -0700, Micha=C5=82 Miros=C5=82aw wrote:
> On Sat, May 07, 2011 at 04:58:07AM -0700, Jeff Kirsher wrote:
> > 2011/5/7 Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>:
> > > As all drivers are converted, we may now remove discrete offload sett=
ing
> > > callback handling.
> > >
> > > Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> > > ---
> > >
> > > Note: This needs to wait for Intel guys to finish conversion of their
> > > LAN drivers.
> > >
> > >  include/linux/ethtool.h   |   52 ------
> > >  include/linux/netdevice.h |   16 --
> > >  net/8021q/vlan_dev.c      |    2 +-
> > >  net/core/dev.c            |   13 +-
> > >  net/core/ethtool.c        |  399 +++--------------------------------=
----------
> > >  5 files changed, 28 insertions(+), 454 deletions(-)
> > I do apologize for the delay, we did find several problems with the
> > original set of patches you submitted during review and testing.
> > Currently we have fixed up the e1000e, yet there is still work to be
> > done on the other drivers.  I will make every effort to make sure that
> > we complete the work over the next week.
>=20
> Ping?
>=20
> Best Regards,
> Micha=C5=82 Miros=C5=82aw

I will be pushing the patches that have passed validation this weekend.
Don is still working on the ixgbe changes, I will work with him to get
the work wrapped up early this week.

Cheers,
Jeff

--=-TTFxgB31u2KZR674Cyu8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJN/OxGAAoJECTsCADr/EWU8fAH/0iRxGiIGpYYsN8Y/2hfNOMy
qxh1DL/EIPKapiDRP1UInmnomXsXH3zsR0l0WeAU8MTSx3CWhhoMSffCMhrOPDm0
OYWoos8mAoIenAkR1XtFwIAx7O+vjUZxSp1bEfjWhU7hH7gZHayueRgwaI5vV8zk
tdkzjMOfXwAMwc0BqqUz3seyoOYO5lYGCiAKdSQi1gU0NE/Wx1gI+9O6YNzj43Ou
yXG/8HwocrrtChe+KTqjjVbHPTY1Su/Jb5uL1SWZlh4tpr3DV39a/ZMsKOLiAhrv
wUxytvL1Xwd2rzghwmtBvkUAkfd5EES7Ztox7ckcEcup67EL19FG0X9coy/w0rI=
=a+TJ
-----END PGP SIGNATURE-----

--=-TTFxgB31u2KZR674Cyu8--

