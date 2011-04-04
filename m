From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next-2.6 00/12] Convert more drivers to ethtool
 set_phys_id
Date: Mon, 04 Apr 2011 13:32:44 -0700
Message-ID: <1301949164.3842.1.camel@jtkirshe-MOBL1>
References: <20110404184340.604594357@linuxplumber.net>
	 <BANLkTimfFPEhr4GozxBZB5Pc-LGXWfGTPQ@mail.gmail.com>
	 <20110404131459.793f67fc@nehalam>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-Wle5w1yNlg2SFn52o7O6"
Cc: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:7251 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755401Ab1DDUcp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2011 16:32:45 -0400
In-Reply-To: <20110404131459.793f67fc@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Wle5w1yNlg2SFn52o7O6
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2011-04-04 at 13:14 -0700, Stephen Hemminger wrote:
> On Mon, 4 Apr 2011 12:53:14 -0700
> Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
>=20
> > On Mon, Apr 4, 2011 at 11:43, Stephen Hemminger <shemminger@vyatta.com>=
 wrote:
> > > Did a bunch of the easy drivers to convert.
> > >
> > >
> >=20
> > I have added patches 3-9 (Intel driver conversions) to my queue of
> > patches.  Thanks Stephen.
>=20
> I changed the behaviour of igbvf for 'ethtool -p' to return not supported=
.
> This seems correct, but it may break somebody who has some weird script r=
unning
> in a virt environment.

I also noticed you did not convert ixgbevf, so we will take a look at
your changes for igbvf and come up with a patch for ixgbevf.

--=-Wle5w1yNlg2SFn52o7O6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJNmirTAAoJECTsCADr/EWUaLwH/ixTkpgkAXtfJVB71CDjc1Fl
zO+K3I83e7L6JTaJIHyMvEE9jGDElpQ1h2R+K2Qn7XEJIqm3G8oIwOczNgG652pR
wxqjg8trzw8IRNYa0JWwFm1VKuy8hfqTxmAraxeMh2pvpVecn8F9+KlsL8/MC3Bz
MvckV6k9gt1ZLhIrZzi1J2ZietHebbsCKaj9uApKN7JbqwqeRV4ADi0Gn2bJ57ak
lcW9RjzAFJOX+QHwjpOQWQElxpovp7SRfa4+T+su5knDWbrBE2NZC5ylzCp9oOGv
h6DcM/UKdNUgkZ37TkY3HedPmM7fq2HMTr4zKdvHu6apgrb2wX4W6aS08lz0Vlw=
=4Dwb
-----END PGP SIGNATURE-----

--=-Wle5w1yNlg2SFn52o7O6--

