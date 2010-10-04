From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 1/2] Revert "ipv4: Make INET_LRO a bool instead of
 tristate."
Date: Mon, 04 Oct 2010 04:54:55 +0100
Message-ID: <1286164495.3916.316.camel@localhost>
References: <1286156262.3916.213.camel@localhost>
	 <20101003.195618.193723845.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-3MwMJQLQQpW7ba2teS1v"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:58822 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751630Ab0JDDy7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Oct 2010 23:54:59 -0400
In-Reply-To: <20101003.195618.193723845.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-3MwMJQLQQpW7ba2teS1v
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2010-10-03 at 19:56 -0700, David Miller wrote:
> From: Ben Hutchings <ben@decadent.org.uk>
> Date: Mon, 04 Oct 2010 02:37:42 +0100
>=20
> > You made the change I want to revert in response to
> > <http://article.gmane.org/gmane.linux.kernel/825646>.  The real problem
> > with its configuration is actually that CONFIG_INET is not set but
> > CONFIG_INET_LRO=3Dm, and the fix is to make CONFIG_PASEMI_MAC depend on
> > CONFIG_INET.
>=20
> Ben, you can't just revert this by itself.
>=20
> That knowingly breaks the build.
>=20
> If you want the tristate back, you must do it after or at the
> same time as fixing the driver deps.

The fact that the driver dependencies are broken has nothing to do with
whether CONFIG_INET_LRO is boolean or tristate.  You fixed a problem
that didn't exist rather than the problem that did.

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-3MwMJQLQQpW7ba2teS1v
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUATKlQDue/yOyVhhEJAQKtuw/+M8ku/H9wOm+VcG8S9g1pc7D4l3K2UgHV
rUILMAHB3BsjUFZjw1rGWDAP3ovZRGRGedNyexMcwGAQOXdcd3Naz/rNaoR0WKnW
iTxtcl73xysjTed951B8IWm/AkqwUYCu4BRWNnm9lISCiGSobC6be6lO8z2LhQM9
pSAu18sTCjZHcTTY1LjLYZFA+RrpF9KjjgDjk95QkhZXAiP4R6kgAJBazxvAVzq7
fVxK5Bq8b5yO45lwCHbCAX014YUoIiSn1qaaBZjOkHqr0MhnnQKGW53USgKzVbtj
fvVHlsi2+SKCWA7vkdw4Js/++eemX6ak1UWbptmYzdncPei0mTjORepmvQpcWhPG
6PA4QHG6TmyJCmw8J9GZF3jxWJyP2CMe29C+vQrVJJVD/CyOgpqJhSa3Q3fUgyrX
8k42LKwC4DRUd5jY6cthkz/MbEP4CkVjDXZxzHjMNibgRw/lVJAPlulVpbaCPegx
NbZWai8EySiBmD1q0onq7bCPh+soh91f9JUeNHBMo4Ts1S3CcZCl5XXw/LJkkiyY
DrQciJjkiy8p70iM+ssxqfgLltaiDzbhRZ4ynfNEx9ilYeipMkqZiVS5Z6jF1dTb
sSg/gLXvpAl2VXAqBZx7tlvXrNLKPqL3DCeXI5UYyyAX3bA0LOnpuEHPUPqB5CWz
b6x0Ukyp7YQ=
=2+Pt
-----END PGP SIGNATURE-----

--=-3MwMJQLQQpW7ba2teS1v--
