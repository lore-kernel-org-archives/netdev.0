From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] igb: fix PHC stopping on max freq
Date: Tue, 19 Mar 2013 17:49:12 -0700
Message-ID: <1363740552.2069.55.camel@jtkirshe-mobl>
References: <f254bc583cbe1f623bd6ebb4ff375e440696d8b2.1363703896.git.jbenc@redhat.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-9apQFkTJ64H9AZFJPcUA"
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	Stefan Assmann <sassmann@redhat.com>,
	Miroslav Lichvar <mlichvar@redhat.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:7655 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757627Ab3CTAtO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Mar 2013 20:49:14 -0400
In-Reply-To: <f254bc583cbe1f623bd6ebb4ff375e440696d8b2.1363703896.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-9apQFkTJ64H9AZFJPcUA
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2013-03-19 at 15:42 +0100, Jiri Benc wrote:
> For 82576 MAC type, max_adj is reported as 1000000000 ppb. However, if
> this value is passed to igb_ptp_adjfreq_82576, incvalue overflows out
> of
> INCVALUE_82576_MASK, resulting in setting of zero TIMINCA.incvalue,
> stopping
> the PHC (instead of going at twice the nominal speed).
>=20
> Fix the advertised max_adj value to the largest value hardware can
> handle.
> As there is no min_adj value available (-max_adj is used instead),
> this will
> also prevent stopping the clock intentionally. It's probably not a big
> deal,
> other igb MAC types don't support stopping the clock, either.
>=20
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
>  drivers/net/ethernet/intel/igb/igb_ptp.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)=20

Thanks Jiri, I have added the patch to my igb queue

--=-9apQFkTJ64H9AZFJPcUA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJRSQeIAAoJEOVv75VaS+3OPz4P+wQEOdxtmoNq+pBsoA6GtqOt
UhW9oYJXTWkJerGoQnlhBkXMRXM6DHeJMWKQyG85zb4hLjh1QLQ0ssWnrZe378MR
zcNWNhu0pKBz997ZobPFlx6k8ctl8h9pkLPNoRIakoAI18gPtN4PE7IOJwM4prgn
9iiOyxogGvfsSIqDmO2wKt+XtY5mDt9PlkK5KmsKo67KCTHG9SAxHRGNIKmQxqC8
f9+7935RbWGUbvs24cjun3SzxlE02XbJQqmxL3P0mMYH6ZXOKSlWWuNKlrkMoPgY
VcFsbc0IqsFU+76ZQO9SAg+PmY73qCpgBcTdHaUFA/KrJ4oXdAne7O8UzQ5qhfv2
9r2ovFEtQ1WeLW30N4HWVMiQ4OKM1vnetTikO7sqcE+9JEbcNP8bIXYxjlxg5Qeu
tfLwdcA7TTGOnXXhNlTS4BmPcovYsBLZeuiEAMFv07T8edCN8zJSzcBs/uf8VfTI
Yce3jdkYOv7mhR/gvbkEcGofNoFuF3uPnR4bTbJgufA3gv9fsotAr1kUvrJyKihZ
8CBcfW9KPQkMPk0KjOqCGVmjq+0VHkyEn7ByrSq30qsCfOneiM+wirhZklqy+2Xt
nyVejxNf3GHB+RqVLimi+I8sYsb5q1RpKVFumJ4KrX9yELaKHFa9ExoB3iANU40b
rf2LHDpEveguS7ToaAJL
=7ciy
-----END PGP SIGNATURE-----

--=-9apQFkTJ64H9AZFJPcUA--
