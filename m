From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 09/14] i40e: Enable all PCTYPEs except FCOE for RSS.
Date: Sat, 07 Dec 2013 11:36:25 -0800
Message-ID: <1386444985.2195.8.camel@jtkirshe-mobl>
References: <1386382643-29055-1-git-send-email-jeffrey.t.kirsher@intel.com>
		 <1386382643-29055-10-git-send-email-jeffrey.t.kirsher@intel.com>
		 <52A36235.1040406@cogentembedded.com>
	 <1386440208.2195.3.camel@jtkirshe-mobl>
	 <52A3812F.4070701@cogentembedded.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-iKqo+tcv9jPS0qxz6FfP"
Cc: davem@davemloft.net,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:40063 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754307Ab3LGTg1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Dec 2013 14:36:27 -0500
In-Reply-To: <52A3812F.4070701@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-iKqo+tcv9jPS0qxz6FfP
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2013-12-07 at 23:12 +0300, Sergei Shtylyov wrote:
> On 12/07/2013 09:16 PM, Jeff Kirsher wrote:
>=20
> >>> From: Anjali Singhai Jain <anjali.singhai@intel.com>
>=20
> >>> RSS can steer packets based on recognition of all
> >>> sorts of different headers.  Enable some more of them.
>=20
> >>> Change-Id: I2264dedae66fb0bceca6fb6e772e050e3ca8efc8
>=20
> >>      This line has no place in the upstream patches, and I'm seeing
> it
> >> in
> >> several patches of this series.
>=20
> > This is an internal hash id, so that we can track upstream changes
> back
> > to internal git tree changes.  I did verify that this was acceptable
> and
> > is being used in the kernel in upstream patches before pushing this
> > information.
>=20
>     First time I hear about that. Its use is constantly denied in
> linux-usb at=20
> least. Maybe netdev has its own rules regarding this though...

Take a look at `git log --format=3Doneline --grep=3D"Change-Id"`
You will see there are instances in arch as well as in wireless and in
other areas as well.  So we are not doing something new or the only ones
using this tag.

Google appears to be using it as well based the following information:
https://gerrit-documentation.storage.googleapis.com/Documentation/2.7/user-=
changeid.html
Places using gerrit:
http://code.google.com/p/gerrit/wiki/ShowCases
This is the largest example of a "Change-Id:" tag that I know of.

--=-iKqo+tcv9jPS0qxz6FfP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABCgAGBQJSo3i5AAoJEOVv75VaS+3O/gAP/0nwjdm09dhIIyxIeTzA3cyd
USITNg3SAbXskmadhJv3U/KCbNfzlu6NBypEKvQ7AQrK1EQ4Jy7jfXqiMlgGsuDI
G/EKsl1C6gbd03B+7VRt8OCOkhqcIzgdSvS5eMHLUckKPZT6wvGCgdDW80fMSYff
Ltw1HUxqkvY2mgjGjcz075T9xONQGY8qDGj6vp/o+c+8dd6T+jIJe5REppBLWZAY
wGC5TDv+QzSqAZ3CNt3L7IEiCzojemWDLNz03XTLXmBBBSTs3pEWGZDb7/rTGPlE
5oCrtYS4B863TSI7vK72MQmsgKTO3oVIa8Y1lEdl9pkx+/NQXjwhIjqfGAOvUwxU
Vg/P9uhn6xmSqtdlfp/nCypDqAgcWTxTWpmriYs8rAdY4Id0R3PBIGMv8v3Ckhx8
ZhEo7KYEwL2ecrlHht5TaldIXcUSJE1crD09YQnd5BFullkxrPfqvmqxO6KOQJyJ
RghDRp0GTbLyfjp4vClT6TOvaMwTv8sF+SUA8PtZtzcFgsrlzDONnnze/ODKu3Tn
W5uZTEiwv0jBHlSwgme93EFHNQIskDuIYJTWvCS7A4AQGWMyB2urb4WBdzr8otfC
aeUlYH/+DrQJD3WgZkVSiQRTsq7PJH9BT2R2MkERQPDAuhl/vM6LUYbw960TmH9M
8uWpyCyzcBdd9bzTM3SC
=vXE0
-----END PGP SIGNATURE-----

--=-iKqo+tcv9jPS0qxz6FfP--
