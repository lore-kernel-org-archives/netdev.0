From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [PATCH] glibc: Terminate process on invalid netlink response
 from kernel [BZ #12926]
Date: Sat, 24 Oct 2015 00:22:03 -0400
Message-ID: <20151024042203.GQ26317@vapier.lan>
References: <562A9391.1040806@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="qnK4RqISe3HuYx1/"
Cc: GNU C Library <libc-alpha@sourceware.org>,
	Hannes Sowa <hannes@redhat.com>, netdev@vger.kernel.org
To: Florian Weimer <fweimer@redhat.com>
Return-path: <libc-alpha-return-64479-glibc-alpha=m.gmane.org@sourceware.org>
List-Unsubscribe: <mailto:libc-alpha-unsubscribe-glibc-alpha=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:libc-alpha-subscribe@sourceware.org>
List-Archive: <http://sourceware.org/ml/libc-alpha/>
List-Post: <mailto:libc-alpha@sourceware.org>
List-Help: <mailto:libc-alpha-help@sourceware.org>, <http://sourceware.org/ml/#faqs>
Sender: libc-alpha-owner@sourceware.org
Content-Disposition: inline
In-Reply-To: <562A9391.1040806@redhat.com>
List-Id: netdev.vger.kernel.org


--qnK4RqISe3HuYx1/
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

On 23 Oct 2015 22:07, Florian Weimer wrote:
> --- /dev/null
> +++ b/sysdeps/unix/sysv/linux/netlink_assert_response.c
> @@ -0,0 +1,100 @@
> +/* Copyright (C) 2015 Free Software Foundation, Inc.
> +   This file is part of the GNU C Library.

guess we like to have the first line be a short desc of the file

> +static int
> +get_address_family (int fd)
> +{
> ...
> +  return sa.ss_family;

ss_family is of type sa_family_t, not int ... not a big deal, but the
two do differ in sign ...
-mike

--qnK4RqISe3HuYx1/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWKwdqAAoJEEFjO5/oN/WBc7QQAKE3wi34T2WiuFmd6j5d3BdY
JO8tReGTNxgp5iW1xXell55DrZcB1jRwVfk9nffIfqpoGoxAUV9jf4OawSQI2ML8
FXHMeRh5bogS1mKAuFExMDNLQfBwsCz4fet7JdaR068JZInWnSlvgkbn7xQVjIee
HXCxdIR4tgqKLVz9QlC6xxCansh6WuhJCkwhS7MvTYaWniHSANY0s/0Y5YAbcwI4
yZed/lWfBWXgqj5g3CtEiSz+MZRmT1EdbWx1+Gr3BwZRgoCb3tb8WsHuUQ6QE7kj
tDPhs/fSox0tD9xj9tmTuAM2dNaHlUj09/SVVylj93PwAInnyzW00RPbnkg8feqs
9bNVw+cmmwOv6bZH8cwBa4Di3To7UO7e7f+jJ4iMuXi4Fth8Da/Tu8vqSyJiKDrV
Vw1cHjUnEBpmuZEu7ytktU71T23UZo5xGj+Zo7jPVE4pSINCpW6J8kVVOoNoYSdY
S3tF/9dYFTKfjpTa215R6A8hDwfjUvmfUHBbTZJjIqqNiOEu921UvBXO7q1TX98r
F7K5lYKzC2ZmPLr03A1EZlKYpo0yayiU7qJlOMboi1CQvpvutg/zdexm+Na4lVvX
runKBwB4pRa8KkaLb09LrEDmmqq7ZviCNsEXPu+S758lIwgeEuGelaPWoj9C04JN
Nm2lsZfke0VRc4KiP8mn
=DKe9
-----END PGP SIGNATURE-----

--qnK4RqISe3HuYx1/--
