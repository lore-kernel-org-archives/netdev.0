From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 1/2] if_link: Add VF multicast
	promiscuous	mode control
Date: Thu, 22 Jan 2015 02:52:46 -0800
Message-ID: <1421923966.2560.30.camel@jtkirshe-mobl>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05E0734E@BPXM14GP.gisp.nec.co.jp>
	<874mrlu18e.fsf@nemi.mork.no>
	<7F861DC0615E0C47A872E6F3C5FCDDBD05E07B7C@BPXM14GP.gisp.nec.co.jp>
	<F6FB0E698C9B3143BDF729DF222866469129B7F5@ORSMSX110.amr.corp.intel.com>
	<7F861DC0615E0C47A872E6F3C5FCDDBD05E07F09@BPXM14GP.gisp.nec.co.jp>
	<F6FB0E698C9B3143BDF729DF222866469129B844@ORSMSX110.amr.corp.intel.com>
	<7F861DC0615E0C47A872E6F3C5FCDDBD05E08FF6@BPXM14GP.gisp.nec.co.jp>
	<063D6719AE5E284EB5DD2968C1650D6D1CAD01D6@AcuExch.aculab.com>
	<7F861DC0615E0C47A872E6F3C5FCDDBD05E090FE@BPXM14GP.gisp.nec.co.jp>
	<F6FB0E698C9B3143BDF729DF222866469129BC03@ORSMSX110.amr.corp.intel.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CAD0C8A@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4933101952277753878=="
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"Choi, Sy Jong" <sy.jong.choi@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Hayato Momma <h-momma@ce.jp.nec.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>,
	=?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAD0C8A@AcuExch.aculab.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============4933101952277753878==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-IdTBaB5t0ET6dPIfMMBX"


--=-IdTBaB5t0ET6dPIfMMBX
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2015-01-22 at 09:50 +0000, David Laight wrote:
> From: Skidmore, Donald C=20
> > > > From: Hiroshi Shimamoto
> > > > > My concern is what is the real issue that VF multicast
> promiscuous mode
> > > can cause.
> > > > > I think there is the 4k entries to filter multicast address,
> and the
> > > > > current ixgbe/ixgbevf can turn all bits on from VM. That is
> almost same as
> > > enabling multicast promiscuous mode.
> > > > > I mean that we can receive all multicast addresses by an
> onerous
> > > operation in untrusted VM.
> > > > > I think we should clarify what is real security issue in this
> context.
> > > >
> > > > If you are worried about passing un-enabled multicasts to users
> then
> > > > what about doing a software hash of received multicasts and
> checking
> > > > against an actual list of multicasts enabled for that hash
> entry.
> > > > Under normal conditions there is likely to be only a single
> address to check.
> > > >
> > > > It may (or may not) be best to use the same hash as any hashing
> > > > hardware filter uses.
> > >
> > > thanks for the comment. But I don't think that is the point.
> > >
> > > I guess, introducing VF multicast promiscuous mode seems to add
> new
> > > privilege to peek every multicast packet in VM and that doesn't
> look good.
> > > On the other hand, I think that there has been the same privilege
> in the
> > > current ixgbe/ixgbevf implementation already. Or I'm reading the
> code
> > > wrongly.
> > > I'd like to clarify what is the issue of allowing to receive all
> multicast packets.
> >=20
> > Allowing a VM to give itself the privilege of seeing every multicast
> packet
> > could be seen as a hole in VM isolation.
> > Now if the host system allows this policy I don't see this as an
> issue as
> > someone specifically allowed this to happen and then must not be
> concerned.
> > We could even log that it has occurred, which I believe your patch
> did do.
> > The issue is also further muddied, as you mentioned above, since
> some of
> > these multicast packets are leaking anyway (the HW currently uses a
> 12 bit mask).
> > It's just that this change would greatly enlarge that hole from a
> fraction to
> > all multicast packets.
>=20
> Why does it have anything to do with VM isolation?
> Isn't is just the same as if the VM were connected directly to the
> ethernet cable?

So give an example of when the VF driver is connected directly to the
ethernet cable and a PF driver (ixgbe) does not exist, at least that is
what you are suggesting.

--=-IdTBaB5t0ET6dPIfMMBX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUwNZ+AAoJEOVv75VaS+3OCt8P/2rvvVTRA0BOZOM8roh22K93
qv5xQOTKEU8awcpp1akhpL1fCZ6maucb67euJI5lm1BOZ5JrZ3amR+CFE4ChOLYG
/1+JIFG4rm3OXhI72gozoTOaOmz9OokKTU26gFaz6QAvkIresWEQwfXBM4nnuh3C
TLx6lbzvlrOgaj9lvQWacCxUKmbtETyKvWaIyMk/LalM0E/REQLZcqVQX56OSDtA
Bn4TMWPtdINoVT/P+0UsdtNhJ4yC+02rcEggjOhBTNTX/TF7vQt4OrYTajbkZQl/
uIHZKRN+16js55BH0EyWJBqXk9UnLnXOATQa0wCfLN079xyyTjZ4j7MDgtxhGJwW
7ZxEGzeh2rrkir6hQEaF5fJ3QvnEEV6yOZutfir4CBaJfT8BrDIWPedsN7jHFXUw
15jgylZAa2R7H2dNeacccdYp8kz9Xf1T65aIYau3E5JHb5vDeFbMncqMcDaLfs9Q
A7cvkAdGqPFVm56NPW2/HO2eVzY7jSmy9+f/syzEW10bI4hVlg/nnFBW0O2Fa0ah
E2EwZdcabsMpcM/e1ZlV/0qrTVq7QJDvywm4hO6lTgvharQARy03YaQLLrqC7dPm
h4T2l1xaXFxqHxyNaD6KPu0cSm90UkmSzolj28EPCVCWeatwTSyPdtOX4CaQo9ap
QMIDvLN0Ph12sTBFaEC4
=RxGs
-----END PGP SIGNATURE-----

--=-IdTBaB5t0ET6dPIfMMBX--



--===============4933101952277753878==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
New Year. New Location. New Benefits. New Data Center in Ashburn, VA.
GigeNET is offering a free month of service with a new server in Ashburn.
Choose from 2 high performing configs, both with 100TB of bandwidth.
Higher redundancy.Lower latency.Increased capacity.Completely compliant.
http://p.sf.net/sfu/gigenet
--===============4933101952277753878==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============4933101952277753878==--
