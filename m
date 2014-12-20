From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [linux-nics] [PATCH] e1000 in linux-3.18.0: a potential bug
Date: Sat, 20 Dec 2014 02:34:20 -0800
Message-ID: <1419071660.2461.85.camel@jtkirshe-mobl.home>
References: <000d01d01c29$a9edb870$fdc92950$@163.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-7MlCBYl6nZEQC5JfJDd1"
Cc: todd.fujinaka@intel.com, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net, linux.nics@intel.com
To: Jia-Ju Bai <baijiaju1990@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:58986 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751040AbaLTKeV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Dec 2014 05:34:21 -0500
In-Reply-To: <000d01d01c29$a9edb870$fdc92950$@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-7MlCBYl6nZEQC5JfJDd1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-12-20 at 15:50 +0800, Jia-Ju Bai wrote:
> I have actually tested e1000 driver on the real hardware(Intel 82540EM
> PCI
> Gigabit Ethernet Controller), and find a potential bug:
> The target file is drivers/net/ethernet/intel/e1000/e1000_main.c,
> which is
> used to build e1000.ko.
>=20
> (1) In the normal process, netif_napi_add is called in e1000_probe,
> but
> netif_napi_del is not called in e1000_remove. However, many other
> ethernet
> card drivers call them in pairs, even in the error handling paths,
> such as
> r8169 and igb.
>=20
> Meanwhile, I also write the patch to fix the bug. I have run the patch
> on
> the hardware, it can work normally and fix the above bug.

Was this a bug you actually saw?  Or a theoretical bug based on code
review?

I do not mind adding this to my queue so that we can review and test the
patch, although this will cause a fair amount of regression testing.

--=-7MlCBYl6nZEQC5JfJDd1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUlVCsAAoJEOVv75VaS+3OR1QP/jj/8vnc1oZJvcXzrN+b5Jej
sYNfHzReiKd8q/llRglcxA7m8eA1SmDOqrXvzv1sAjNVjUNKXuhGzuDUKKGA98EU
oos+sJBLfr8Olk0rXuMwWUUDIj3HjMdwINoq1HmgG3amhxlIUpSD7rThL1ma16+L
p/sUbfn1CohQ8NkMWQBd6GHMZE+6/VOVyQXKJjUQ8+ES+RN8v5xnNR2Elg6F+1XN
8fxMg8PVTjLYZ0cTQtRcuztcKQcWqr/CWL7cxrltVqwPLh4Du8+gqpqFjdKimRmU
D/ntSwUz+a/8jK/iaFh0wwkbPdfBmB1Jfcil34BI+IPZ+0mk1byuWDVHFvd1Qczb
GghrDtoidrusnD9MWeYjDEoaJeiMLtCf/9KH1Dnl/JsFYjbicwTqyjW60C/V49qY
Gj7oQR0JN3wOncF6qGs2vFYrFvRGb+dfvC6wcci+SNdipmNv5X1GXFRy04E75Akw
F1zGgGVT9oYxCbNJxnIB8C/Hf50ykLZbOBYb5unCDgGQu7/3eqYc7xQXo+dTvykN
f9qArmX/J6rbKvFUntEeaV/0sExunRmaRyUOClM5SRFoOwJWCTw4DBR4i872oPvK
wv6loRZCvjKx4c81qz6x4SHmirU78wkcfpvyVMWXiqB7mvAH/qKTjTnIuSOcUg0A
KXV70w10p6a/lm5T83mL
=PAYW
-----END PGP SIGNATURE-----

--=-7MlCBYl6nZEQC5JfJDd1--
