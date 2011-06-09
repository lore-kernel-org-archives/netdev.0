From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 00/12][pull request] Intel Wired LAN Driver Update
Date: Thu, 09 Jun 2011 00:53:14 -0700
Message-ID: <1307605995.32044.18.camel@jtkirshe-mobl>
References: <20110609.000505.2259375858864240000.davem@davemloft.net>
	 <20110609.000823.2202058578852433528.davem@davemloft.net>
	 <1307605611.32044.16.camel@jtkirshe-mobl>
	 <20110609.005051.1530473933808285841.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-uHQoc2sJFc0ItZyLP2Yf"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:33005 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752569Ab1FIHxb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2011 03:53:31 -0400
In-Reply-To: <20110609.005051.1530473933808285841.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-uHQoc2sJFc0ItZyLP2Yf
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2011-06-09 at 00:50 -0700, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Thu, 09 Jun 2011 00:46:50 -0700
>=20
> >> Actually, I have to un-pull.  Please build test your changes:
> >>=20
> >> drivers/infiniband/core/netlink.c: In function =E2=80=98ibnl_rcv_msg=
=E2=80=99:
> >> drivers/infiniband/core/netlink.c:151:9: error: too few arguments to f=
unction =E2=80=98netlink_dump_start=E2=80=99
> >> include/linux/netlink.h:260:12: note: declared here
> >> make[3]: *** [drivers/infiniband/core/netlink.o] Error 1
> >> make[2]: *** [drivers/infiniband/core] Error 2
> >> make[1]: *** [drivers/infiniband] Error 2
> >> make[1]: *** Waiting for unfinished jobs....
> >=20
> > I built tested after every patch and did not have any issues.  I see
> > Greg made some changes to include/linux/netlink.h which may be the
> > result of this error.
>=20
> Well of course, the arguments to netlink_dump_start() changed and therefo=
re
> every call site needs to be updated.
>=20
> Unless you don't have infiniband enabled in your builds, you should be
> hitting this build failure too.

Just did, I saw that I did not have enabled and I got the same issue.  I
am looking into now, and will check to make sure there were no other
netlink_dump_start() references missed as well.

--=-uHQoc2sJFc0ItZyLP2Yf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJN8HvqAAoJECTsCADr/EWU2McIAKBtFdQmA1A8yQ5t/NL4BaHu
Qm8/XZNf9/aiSVUdGBTa+Q4fb8oNP1VZuif7hpRVxtEkhlUwagbj3mMGSQzu8VVd
tctbc6RFHlygJ+Hy5O+C4M5g9QlY92B31mKRxHX4egyIL0b/pKWts+Tk6z2v6nhr
XeYGEhMvPkT38x6eFp6CXDMyftokz8h4oBURA5hT3OXSRo6dyCzcv5DINbV0yQhx
dpmSI3cVbyAx9Ps9K/jzbFmrKlX2QNUSLhOmsWLUFw35EMmT6AiwAm8kJV0BE1JB
W3bFr3PvJMIk5wJpzSDAUEztT9Ddyexwd49YUZVHULr7OQ1AoKj0svbHIEJp5ps=
=Cksq
-----END PGP SIGNATURE-----

--=-uHQoc2sJFc0ItZyLP2Yf--

