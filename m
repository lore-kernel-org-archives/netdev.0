From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: [RFC] ehea: kdump support using new shutdown hook
Date: Thu, 13 Dec 2007 17:30:24 +1100
Message-ID: <1197527424.7695.43.camel@concordia>
References: <200712121753.43543.osstklei@de.ibm.com>
	 <20071212170440.GD2359@redhat.com>
Reply-To: michael@ellerman.id.au
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-tGfd8eIMJyAvH2YKdVzf"
Cc: Thomas Klein <osstklei@de.ibm.com>,
	Paul Mackerras <paulus@samba.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Stefan Roscher <stefan.roscher@de.ibm.com>,
	Michael Neuling <mikey@neuling.org>
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:44478 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751624AbXLMGaZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2007 01:30:25 -0500
In-Reply-To: <20071212170440.GD2359@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-tGfd8eIMJyAvH2YKdVzf
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-12-12 at 12:04 -0500, Dave Jones wrote:
> On Wed, Dec 12, 2007 at 05:53:43PM +0100, Thomas Klein wrote:
>=20
>  > +static void ehea_update_adapter_handles(struct ehea_adapter *adapter)
>  > +{
>  > +	int i, k;
>  > +	int j =3D 0;
>  > +
>  > +	memset(adapter->res_handles, sizeof(adapter->res_handles), 0);
>=20
> arguments wrong way around.

Remind me why bzero is deprecated again? :)

cheers

--=20
Michael Ellerman
OzLabs, IBM Australia Development Lab

wwweb: http://michael.ellerman.id.au
phone: +61 2 6212 1183 (tie line 70 21183)

We do not inherit the earth from our ancestors,
we borrow it from our children. - S.M.A.R.T Person

--=-tGfd8eIMJyAvH2YKdVzf
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHYNGAdSjSd0sB4dIRAoFEAJ9QM6YR0cPfq81FGpxCjKh30Q7reACcCJ7i
/EUszDgbpmAvWyZO1o1oXHg=
=jX6N
-----END PGP SIGNATURE-----

--=-tGfd8eIMJyAvH2YKdVzf--

