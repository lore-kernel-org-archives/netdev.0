From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] i40e: Fix possible memory leak in i40e_dbg_dump_desc
Date: Sun, 07 Dec 2014 11:57:32 -0800
Message-ID: <1417982252.2399.51.camel@jtkirshe-mobl>
References: <20141206134513.GD4963@mwanda>
	 <1417874601.31745.21.camel@perches.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-j/VC/N6D3Dawk0//NSJb"
Cc: kbuild@01.org, Shannon Nelson <shannon.nelson@intel.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	netdev <netdev@vger.kernel.org>, nhorman@redhat.com,
	sassmann@redhat.com, jogreene@redhat.com
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:2398 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752411AbaLGT5e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Dec 2014 14:57:34 -0500
In-Reply-To: <1417874601.31745.21.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-j/VC/N6D3Dawk0//NSJb
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-12-06 at 06:03 -0800, Joe Perches wrote:
> I didn't notice that return in the code, fix it by
> adding a goto out instead to free the memory.
>=20
> Fixes:
>=20
> > New smatch warnings:
> > drivers/net/ethernet/intel/i40e/i40e_debugfs.c:832
> i40e_dbg_dump_desc() warn: possible memory leak of 'ring'
>=20
> Signed-off-by: Joe Perches <joe@perches.com>
> Noticed-by: Dan Carpenter <dan.carpenter@oracle.com> (go smatch)
> ---
>=20
> Jeff Kirsher can legitimately give me a hard time now...
> Thanks Dan.
>=20
>  drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)

Thanks Joe, I have added your patch to my queue.

--=-j/VC/N6D3Dawk0//NSJb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUhLEsAAoJEOVv75VaS+3OY/sP/3RM/UzqBXWV6klNoFFhHq1z
WWjJ3MuXyzAeIvvVLSB605/+tYV/f2ClMKc2Pw052Sr5Nkh5PtDoMqnyf1iORsND
pTUtpXK2qntwdyG59MvSE3GZzaBNTLODiRRJts77Gg21OtGdDvcuBsMi65jA3qgX
ku11qS02VEzbc8E1dvCANqBHXaFFYP6EVQdIFr92qVERFKZWbKrzgfNnTex9XSD+
+5QlYMtFzmWyfBMEyduBK8ZdT3ALQ1UsUQ62LKVUaBQGNVnmJjAH7ODttGylLnmw
5qboolQFDOXs3yMeMsYGHWx8022rrFHkHBIgwaHRE9nrNmQe5jw/dmQjmAc3PtLQ
6/veplyJsxZo6rbWCQ5RB5VJtLJvkC91bxthYMBilsDbd0+0H8QDhNDg3n4/Ygvm
UoIrNZM1RP52w4pbqgyJgh7CiXhjJqeX5Tqf7vVJYWvByY79AmteIIylNmEUyXtX
8jbnfKpBQ3asa82Vwxl5oIsNId01VCJ7KFofprq3Al3zFcxlRMsIJ2Y0fcr/2DhG
pVjwdqrBJOtd6ccnuVxeeTItRFekgU8Mkr6Zdj28n7HJfBvZEQjQj4WhFFdvTH0Y
tMPej+Px2kPtTnUhlq0/YMd9XsI+RmNQZ+0rYVrrsjeSqqEw4lSKZvMKx6KBM6Rs
2LXQb6QBPht8OTHehkPL
=YYpQ
-----END PGP SIGNATURE-----

--=-j/VC/N6D3Dawk0//NSJb--
