From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v2 2/3] if_link: Add VF multicast promiscuous control
Date: Mon, 23 Feb 2015 13:14:18 -0800
Message-ID: <1424726058.2647.8.camel@jtkirshe-mobl>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05E38840@BPXM14GP.gisp.nec.co.jp>
	 <54E73BE4.2040505@solarflare.com>
	 <F6FB0E698C9B3143BDF729DF22286646912AD3E7@ORSMSX110.amr.corp.intel.com>
	 <54EB30A1.9080309@solarflare.com>
	 <F6FB0E698C9B3143BDF729DF22286646912ADAD5@ORSMSX110.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-4AnddlWq563teKgaIYGH"
Cc: Edward Cree <ecree@solarflare.com>,
	Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	=?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Choi, Sy Jong" <sy.jong.choi@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Laight <David.Laight@ACULAB.COM>,
	Hayato Momma <h-momma@ce.jp.nec.com>
To: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <F6FB0E698C9B3143BDF729DF22286646912ADAD5@ORSMSX110.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-4AnddlWq563teKgaIYGH
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2015-02-23 at 06:29 -0800, Skidmore, Donald C wrote:
> > -----Original Message-----
> > From: Edward Cree [mailto:ecree@solarflare.com]
> > Sent: Monday, February 23, 2015 5:53 AM
> > To: Skidmore, Donald C
> > Cc: Hiroshi Shimamoto; vyasevic@redhat.com; Kirsher, Jeffrey T; Alexand=
er
> > Duyck; Bj=C3=B8rn Mork; e1000-devel@lists.sourceforge.net;
> > netdev@vger.kernel.org; Choi, Sy Jong; linux-kernel@vger.kernel.org; Da=
vid
> > Laight; Hayato Momma
> > Subject: Re: [PATCH v2 2/3] if_link: Add VF multicast promiscuous contr=
ol
> >=20
> > On 20/02/15 21:05, Skidmore, Donald C wrote:
> > > If a vender specific interface is objectionable maybe a simpler and m=
ore
> > generic interface would be for the PF to be able to set a given VF into
> > "trusted" mode... I admit exactly what 'trusted' meant would vary from
> > vender to vender, but it would be a way for the driver to know it could=
 allow
> > configurations such as this.  Just an idea, since we seem to be getting=
 more
> > requests for things such as this.
> > That's an even worse idea; now you have a generic interface with comple=
tely
> > undefined semantics.
> > The right way to do this, imho, is to use one of the standard interface=
s for
> > driver-specific gubbins - e.g. sysfs, genetlink or even (whisper it) io=
ctls - and
> > put your 'VF promisc mode' setting there.  That way you have a vendor-
> > specific interface with vendor-specified semantics.
> > Of those options, I'd recommend sysfs as the best fit.
> > The information contained in this message is confidential and is intend=
ed for
> > the addressee(s) only. If you have received this message in error, plea=
se
> > notify the sender immediately and delete the message. Unless you are an
> > addressee (or authorized to receive for an addressee), you may not use,
> > copy or disclose to anyone this message or any information contained in=
 this
> > message. The unauthorized use, disclosure, copying or alteration of thi=
s
> > message is strictly prohibited.
>=20
> I do see your point, but I thought custom sysfs interfaces (not to even m=
ention new ioctl's :) were frowned upon?  Which is why I didn't even consid=
er sysfs as an option.

We discussed this during NetConf last week, and Don is correct that a
custom sysfs interface is not the way we want to handle this.  We agreed
upon a generic interface so that any NIC is able to turn on or off VF
multicast promiscuous mode.

--=-4AnddlWq563teKgaIYGH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJU65gqAAoJEOVv75VaS+3O6dQP/2tJdXu5lg2e2x85N0efz7k8
0kNcyW6oyvGqQs+D+k6JKzRkPgwTZHkd3tD4SuJIICBZB8QhcCzb3c0EIqe9hlbp
o/6NSFx7XjUXFHxBhIXyx4CJd8fc4m+AC4BGaVCEM7DFrANSQUtwvskuF3WducN7
xPysW00KrZfLYS+3Wsm818aBCdiiCZC4f9KdPheziM8po7fSw0pI6P9h9c7hvBeu
M70Iklo7PLQAcT3BNavU1lOywkf920QHYR/Upt23B4yoOC+t7T3+eguVDbHb5V6l
nqvYUUfQUkrzewqPmzAsqwmorT89ipjT9S9mm8plIeWxohusqbVPEkWIbV4ZADFx
DcaRmwiVTfe5QL4ASjSIu+5Z+79kUde+hi3qi4ifN9/lP4Cekmlv4gUnIGFOeVFI
HS6G/ztkWLf1VCU87xNerPPQKDIXu/ZL8X9X4Zco3GaeYfSIC21+G4f8neYVDC+1
szqDeCY8Qdb18n2FL+BNWmEPYJpEFTmpLk0Fy4I2QCea9NAgk9mqFyxo387Ncx03
VA/gB6fUDiAKnyjU1azdQf2esl8cg9x1jh7SODh0HUT+OvGpK2vgWhBpJotTz/5B
ZkpFQWTSqoXXhziG1aBjZSt/wsNLKEX5d3TsHmaJyXm7bfcZxKR6hhJMINT2w80J
7m6Y64EHyWOUlXkcQrQk
=+7gF
-----END PGP SIGNATURE-----

--=-4AnddlWq563teKgaIYGH--
