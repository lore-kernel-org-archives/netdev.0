From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next-2.6 2/2] e1000e: use GFP_KERNEL allocations at
 init time
Date: Mon, 11 Jul 2011 19:40:31 -0700
Message-ID: <1310438432.2438.26.camel@jtkirshe-mobl>
References: <1310421182.2860.22.camel@edumazet-laptop>
	 <CAL3LdT7WNrkDk2WrTnDnwYJ2raoNJdG5v4q=gk4o8hc2KR1Q_w@mail.gmail.com>
	 <20110711.193359.1440272794251078589.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-RJmzBBTyrAOkDd68afis"
Cc: "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"greearb@candelatech.com" <greearb@candelatech.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:62504 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753679Ab1GLCkc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2011 22:40:32 -0400
In-Reply-To: <20110711.193359.1440272794251078589.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-RJmzBBTyrAOkDd68afis
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2011-07-11 at 19:33 -0700, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Mon, 11 Jul 2011 16:51:23 -0700
>=20
> > On Mon, Jul 11, 2011 at 14:53, Eric Dumazet <eric.dumazet@gmail.com> wr=
ote:
> >> Note : This patch is untested, I dont have the hardware
> >>
> >> Thanks
> >>
> >> [PATCH net-next-2.6 2/2] e1000e: use GFP_KERNEL allocations at init ti=
me
> >>
> >> In process and sleep allowed context, favor GFP_KERNEL allocations ove=
r
> >> GFP_ATOMIC ones.
> >>
> >> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> >> CC: Ben Greear <greearb@candelatech.com>
> >> CC: Bruce Allan <bruce.w.allan@intel.com>
> >> ---
> >>  drivers/net/e1000e/e1000.h  |    2 +-
> >>  drivers/net/e1000e/netdev.c |   33 +++++++++++++++++----------------
> >>  2 files changed, 18 insertions(+), 17 deletions(-)
> >>
> >=20
> > Thanks Eric!  I have added the patch to my queue.
>=20
> You can't until I put patch #1 into my tree, which adds the
> new interfaces used by this patch.

I applied patch #1 to my queue as well (for testing purposes) since I
saw that patch #2 was dependent.  If it passes testing, I (or Bruce)
will just ACK patch #2, that way you can apply both patches at the same
time.

--=-RJmzBBTyrAOkDd68afis
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOG7QfAAoJECTsCADr/EWU/v0IAJ0YK7YidIDm2+0R7DF3ZdWa
OwuVIps7zR65299Tp7qaeyUeEy3k5jWyST90bAGgHluUk2570JxcD85Hg25xHSqT
kskmHINCUwdPOdcq0514nlLbjFxDSV4cmfwL6Py8IDR85NIAoHqVk7/rG/PF+Xnb
VtyACslD0taA5gvzbn+Kqyzbxn7U2o5aXlD9x09TnhgGV2GDUQLfXbH9YCmXpCz8
kLTJddW9xaSn/veGTdwQEHnUkkn1eamvsMRCEnkoXXLNfFaDVjHGxBVrVurFBp+5
vikkjL/3TQgLEziZ9isU/g1R1oU+eLujnuhPpxyp2pY1Uec3oqu1Wajf4XSBYTU=
=ltOI
-----END PGP SIGNATURE-----

--=-RJmzBBTyrAOkDd68afis--

