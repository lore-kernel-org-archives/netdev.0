From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net V4 0/2] igb: ptp hardware clock
Date: Fri, 27 Jan 2012 02:56:29 -0800
Message-ID: <1327661789.2729.57.camel@jtkirshe-mobl>
References: <cover.1327161325.git.richardcochran@gmail.com>
	 <1327638293.2729.43.camel@jtkirshe-mobl>
	 <20120127101119.GA6690@netboy.at.omicron.at>
	 <1327659327.2729.55.camel@jtkirshe-mobl>
	 <1327659761.2220.0.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-SN9iM80jqiYsFxp7jala"
Cc: Richard Cochran <richardcochran@gmail.com>,
	"Brown, Aaron F" <aaron.f.brown@intel.com>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net,
	Jacob Keller <jacob.e.keller@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:55768 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752758Ab2A0K4b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jan 2012 05:56:31 -0500
In-Reply-To: <1327659761.2220.0.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-SN9iM80jqiYsFxp7jala
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2012-01-27 at 11:22 +0100, Eric Dumazet wrote:
> Le vendredi 27 janvier 2012 =C3=A0 02:15 -0800, Jeff Kirsher a =C3=A9crit=
 :
> > On Fri, 2012-01-27 at 11:11 +0100, Richard Cochran wrote:
> > > On Thu, Jan 26, 2012 at 08:24:53PM -0800, Jeff Kirsher wrote:
> > > > Richard-
> > > >=20
> > > > Did you compile test?  Why I ask is our validation team is getting =
the
> > > > following errors when trying to compile in PTP support:
> > >=20
> > > I did compile and also tested the driver.
> > >=20
> > > What .config are you using? What kernel version?
> > >=20
> > > Thanks,
> > > Richard
> >=20
> > I will have Aaron post his .config's that he tried.  I know that he
> > tried multiple configs with no success.  As far as kernel version, he
> > was using the latest net-next tree from David Miller.
>=20
> This might coming from
>=20
> commit 36a1211970193ce215de50ed1e4e1272bc814df1
> Author: Paul Gortmaker <paul.gortmaker@windriver.com>
> Date:   Tue Jan 24 11:33:19 2012 +0000
>=20
>     netprio_cgroup.h: dont include module.h from other includes
>    =20
>     A considerable effort was invested in wiping out module.h
>     from being present in all the other standard includes.  This
>     one leaked back in, but once again isn't strictly necessary,
>     so remove it.
>    =20
>=20
>=20

Eric was correct.  I added #include <linux/mdoule.h> to the igb_ptp.c
file and the error goes away.

Richard are you fine with me adding that change to your first patch of
the series?  That way I can have the validation team finish up testing
your patches.

--=-SN9iM80jqiYsFxp7jala
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJPIoLdAAoJEOVv75VaS+3Onm4P/2zntEROkw9eDptD3QW1Wo52
4yxV6pflGBQdDI5Lt8GAi71sBQMtjRiIGxMNEjv8oDczsA/sUdbRte32u8pdKkWh
cYawxNMDnyNYaz3Bpuz80xr7Mw2oFQuyNggrjOAuV6PL6FkVQarkezqfrhRgli78
GtX5wmafvxOoqWGdGdFvIqzqKLFdNRQMR4UrBbs64JCbQuD08S766fyNrHdmpNno
IzaYUuG8aseYJmJ3qLc3PySeXX8pU8bMM1QMCaaXyhllwm4M4+iYW5yJAki537Xg
S3y4ToeidCwLOnAhJfSA5D7AcUkCIYj5KWOCoTEcl1LzQQoKgIeCPRJxg3JWt6dZ
xvyFbIe8iSExmHseYdadf5U27poyWqsTJf5dB2OB9hIhFfIOuY6HH5aWgiGZL4E4
7f2fsGIxOaom+YGJgc8WrrkcvpfqJDoxqigy9k/pXzGQ7GmkbpqdqGPIn2SXsaM4
AkZ5/4NOTs/Bw09CHRWqrBCcG8JyRl6iI1LFZw0rMFOfUi47q54Xvb9Hp9su219d
RPy+ujMivSYOfY2eCmoDaLzNNfhAAgvg92ZkJpKK+t0GcXgmLJPJZmfRW4wbxRpP
6ZHWWYz+qZZS6kAkALabZJJIWixbLQb9Ue0lYZwSSw6WLBOXoFMCVGvGmMWdztlX
SmNrycjojJDJMDdf9Tug
=E+FP
-----END PGP SIGNATURE-----

--=-SN9iM80jqiYsFxp7jala--
