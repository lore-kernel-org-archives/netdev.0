From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 00/12][pull request] Intel Wired LAN Driver Update
Date: Thu, 09 Jun 2011 00:46:50 -0700
Message-ID: <1307605611.32044.16.camel@jtkirshe-mobl>
References: <1307573800-24868-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20110609.000505.2259375858864240000.davem@davemloft.net>
	 <20110609.000823.2202058578852433528.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-OGkphsgT961tFXzcv+kR"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:20682 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752569Ab1FIHqw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2011 03:46:52 -0400
In-Reply-To: <20110609.000823.2202058578852433528.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-OGkphsgT961tFXzcv+kR
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2011-06-09 at 00:08 -0700, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Thu, 09 Jun 2011 00:05:05 -0700 (PDT)
>=20
> > From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date: Wed,  8 Jun 2011 15:56:28 -0700
> >=20
> >> The following series is a (smaller) subset of the previous 40 patch
> >> submission.  This subset only contains updates to e1000e, igb, igbvf
> >> and rtnetlink.
> >>=20
> >> e1000e: several cleanups and fixes, as well as bump the version
> >> igb/igbvf/ixgbevf: bump driver version
> >> rtnetlink: Compute and store minimum ifinfo dump size
> >>=20
> >> The following are changes since commit ffbc03bc75b39c7bd412e7cc6d2185c=
11b0ffedd:
> >>   net: add needed interrupt.h
> >> and are available in the git repository at:
> >>   master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6 ma=
ster
> >=20
> > Pulled, thanks Jeff.
>=20
> Actually, I have to un-pull.  Please build test your changes:
>=20
> drivers/infiniband/core/netlink.c: In function =E2=80=98ibnl_rcv_msg=E2=
=80=99:
> drivers/infiniband/core/netlink.c:151:9: error: too few arguments to func=
tion =E2=80=98netlink_dump_start=E2=80=99
> include/linux/netlink.h:260:12: note: declared here
> make[3]: *** [drivers/infiniband/core/netlink.o] Error 1
> make[2]: *** [drivers/infiniband/core] Error 2
> make[1]: *** [drivers/infiniband] Error 2
> make[1]: *** Waiting for unfinished jobs....

I built tested after every patch and did not have any issues.  I see
Greg made some changes to include/linux/netlink.h which may be the
result of this error.

--=-OGkphsgT961tFXzcv+kR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJN8HpqAAoJECTsCADr/EWU+RcH/AlIf7Qy18dME27sWeIrqCF/
1uKgqaXwTSUrYQTYNd233lIram8cm9otBzE/Jv4J//vd3dhpLVrWXE2ZvGpTuoAY
EX+ImFDQeBg5zBxd3MBYcTusvIT1YEjkINOIDbhDqsPhG35Az7ZVEqLSRjgdvHSr
LnZgaQLshVEOrou/CvVP7uMSQbpDG3kcv+WLzk6SnW6x4BYFqpX6/A+ZSnEsO6SI
9GIj/gbiQ4V5kHqssHG8OUq4My6tduj4wT8Q5inEf9SqBF5MMEPs1CNkMfNbUWSF
yZYLXcPZRAPsiXxcfmgEO26oV9ZIT1vKNKyqWoLVF5V/P16AOf2P2tZMzWT2IYo=
=H4Yz
-----END PGP SIGNATURE-----

--=-OGkphsgT961tFXzcv+kR--

