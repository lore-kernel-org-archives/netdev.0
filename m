From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 04/39] wimax: internal API for the kernel space WiMAX
	stack
Date: Thu, 27 Nov 2008 10:43:19 +0100
Message-ID: <1227778999.3809.34.camel@johannes.berg>
References: <cover.1227691434.git.inaky@linux.intel.com>
	 <960be5a67120268108e2b252921161762fac9aeb.1227691434.git.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-KJ/reI9PIu1d9o/gCWyk"
Cc: netdev <netdev@vger.kernel.org>
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:54208 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751677AbYK0JpQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 04:45:16 -0500
In-Reply-To: <960be5a67120268108e2b252921161762fac9aeb.1227691434.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-KJ/reI9PIu1d9o/gCWyk
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2008-11-26 at 15:07 -0800, Inaky Perez-Gonzalez wrote:

> +static inline __must_check
> +int wimax_dev_is_ready(struct wimax_dev *wimax_dev)
> +{
> +	if (wimax_dev->state =3D=3D __WIMAX_ST_NULL)
> +		return -EINVAL;	/* Device is not even registered! */
> +	if (wimax_dev->state =3D=3D WIMAX_ST_DOWN)
> +		return -ENOMEDIUM;

ENOLINK seems more appropriate?


> +/*
> + * The concept of a pipe -- we encapsulate it because we want to
> + * detach the usage of it from the implementation, and thus it serves
> + * just as a handle.

Might help to explain just what the concept is :)

johannes

--=-KJ/reI9PIu1d9o/gCWyk
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJLmuzAAoJEKVg1VMiehFY7hcQAL7wtm8EFSfAMHEBJkCp6zZn
HIN5FlGxdV+A2HEUhJ2dGUbfdicWsVMGK+ZcLFB/k5QdUEe4VQMYvcHsispu7vcm
+ZPAgiI7uOl7YBfEms1hTQ4lAGVSeJ/OlQ+VvQCTKK4GkkjYlVV/jJ05rWtS48Oy
0if9kdsg4kCjcKV5dNSaVpCfSkbaPRZyyn/LN6LgwHias8K/XUuMKHNa8V6wr8pb
G72dbyYyw05D8e9tRrAXXC54EF+pgSAOWsnICmwK0AAhhKsCNGq6UxkaqOrxprUE
kTaSOUEXr2OvMM0L8wkqYXXaol9NKXk0C9qzrEjcvcgNnYuk6mDOH2Tx30cmHLzv
24sTw6bQSIhlk74NmLgjleWEy6TcjudrZOwfTuWFgOMCxucJJG+U8EOMeKl4s7JE
V1wcvFOlrWuzuXCZOL7bSgX3YQFLvdN1HLUBu062yOA8zaszCN1ht1AAW3rWE0D9
f9+p4TeieEWF5m8gpWTBk5PtjSnkaS2mVQ9vHRtdoRVLDHCCBCo/+Wu1IWTLyLfi
xqeRmtU0ZgCuC5DMOk9NPB14B9YOxurpltq0YJu0tbGjSUjbG58RDav7zyxto+cw
U/9tAS/xRUXZFtpCHDq7rjVjDJoV9xO84R4r1GRnT2rlbAbVfNpehl7zxV9QnFIv
Snn20jOgQVsbhm5cJJOF
=q4in
-----END PGP SIGNATURE-----

--=-KJ/reI9PIu1d9o/gCWyk--

