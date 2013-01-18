From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 04/14] e1000e: add support for IEEE-1588 PTP
Date: Thu, 17 Jan 2013 22:27:35 -0800
Message-ID: <1358490455.23148.14.camel@jtkirshe-mobl>
References: <1358422519-20981-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1358422519-20981-5-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20130117075626.40eb1500@nehalam.linuxnetplumber.net>
	 <804857E1F29AAC47BF68C404FC60A1843ABB7F00@ORSMSX102.amr.corp.intel.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-l3XE/Y1uww/uwMZxeCKF"
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	Richard Cochran <richardcochran@gmail.com>
To: "Allan, Bruce W" <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:25784 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750830Ab3ARG1h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2013 01:27:37 -0500
In-Reply-To: <804857E1F29AAC47BF68C404FC60A1843ABB7F00@ORSMSX102.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-l3XE/Y1uww/uwMZxeCKF
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2013-01-17 at 17:13 -0800, Allan, Bruce W wrote:
> > -----Original Message-----
> > From: Stephen Hemminger [mailto:stephen@networkplumber.org]
> > Sent: Thursday, January 17, 2013 7:56 AM
> > To: Kirsher, Jeffrey T
> > Cc: davem@davemloft.net; Allan, Bruce W; netdev@vger.kernel.org;
> > gospo@redhat.com; sassmann@redhat.com; Richard Cochran
> > Subject: Re: [net-next 04/14] e1000e: add support for IEEE-1588 PTP
> >=20
> > On Thu, 17 Jan 2013 03:35:09 -0800
> > Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
> >=20
> > > +static struct ptp_clock_info e1000e_ptp_clock_info =3D {
> >=20
> > Should be static const since it is immutable and contains function poin=
ters.
>=20
> Nice catch!  Thanks for the review Stephen.  I'll submit a follow-on patc=
h to change this
> if that is alright with you.  Btw, did you catch that through inspection =
or did you use a
> static analysis tool?
>=20
> Bruce.

Bruce-

I have to make some other changes in the series of patches, so we can
just fix up this patch for when I re-submit the series of patches.

Cheers,
Jeff

--=-l3XE/Y1uww/uwMZxeCKF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQ+OtXAAoJEOVv75VaS+3OYyoQAJ7WAORm0eY7LwxR5tzarHA6
ZsaVG+RUZgVUD4WoDPThbCm+gqQ4SGG2JKdY0ECF6V1UPYJxq6DN68cq6SJlXXxm
IbfYGAGFi4bmKhLxHJRwOtbqeB4+6hB09ljVaAzkI0cSNDULNldTAHCMzAQu2vJZ
tR64wEtL3k1IYSXdu3lospOkRV/jXyEH+jlD3Hi4Usw9l6Tx3E+Tc35nCMQS2V8D
tC5GU2JhWsIhQgvisNA1+QFnkZB4mkvXkuv/sHA/9lufe+D2hInPZ2K6xGwFAZgC
MnyWYPVmJZPLxVyis8TcXo0vhoH70cc878+hqsi23tYrWDmTj4Me6zrYBL1nz+jE
YsJS513Z2PMXK8mOLsmuNTEnokSwcsDh5nfhk88borAB7p7eMumAsLUeTp2mX1iq
1pdF1BgtDkhx02HHTQgxXB/T1ZpGesBXHE5wtgDMUpeS4MPuouSuCbR14eaNcPxC
tVNZnirmMX9IpjaJZnsqrb1Jd8uoxul8l5yqWMLNdoYX7auRtYMgHslKnrn9xB0i
Pk9zI96jKsyx8HbRVv/9yzgG5JvIxx5ZEBP2zqnbeCxcY7hza8hql/du2/LU8LfQ
ZXHj/RcMeSDRT1ra/Rsnc/0Fs+ry0Ixo958C7TX3MSDBT4JlvsG+R79b6FTz3hbH
LpFk4qcHM9U7GRTmZaEg
=yvXn
-----END PGP SIGNATURE-----

--=-l3XE/Y1uww/uwMZxeCKF--
