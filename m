From: Wesley Eddy <weddy@grc.nasa.gov>
Subject: Re: TCP rto estimation patch
Date: Fri, 23 Apr 2004 16:44:34 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040423204434.GA7492@grc.nasa.gov>
References: <20040423142445.GC501@grc.nasa.gov> <200404231735.i3NHZRp3012111@eeyore.valparaiso.cl>
Reply-To: weddy@grc.nasa.gov
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ZGiS0Q5IWpPtfppv"
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Horst von Brand <vonbrand@inf.utfsm.cl>
Content-Disposition: inline
In-Reply-To: <200404231735.i3NHZRp3012111@eeyore.valparaiso.cl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--ZGiS0Q5IWpPtfppv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Apr 23, 2004 at 01:35:27PM -0400, Horst von Brand wrote:
>=20
> Why RTT_ALPHA and RTTVAR_BETA, and not just RTT_BETA? Or even RTO_xxx?
>

Per the spec, alpha is used to compute rtt and beta likewise for rttvar.
=20
> Is there any reason to change them, ever? What happens if you change them?
> Restrictions on values? All this should go with such a patch IMHO (at lea=
st
> pointers to relevant discussion).

The information isn't relevant since the patch didn't change them, and if
you were interested in changing the values then simple google search
would return a plethora of research on RTT estimation.

> Must go over it with a fine comb to make sure no unrelated 2 or 3 got
> replaced... out of my league, sorry.

There are stray constants all over the place, which is something that
even freshman computer science students are taught to avoid.  This patch
represents a minor improvement to that situation.

-Wes

--ZGiS0Q5IWpPtfppv
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFAiYAyzBuYqbnj3IwRAjhPAKCBRdDgGsALp9DTh5qFK+41cTEb6QCfUENV
XM5O6g2f/gEt/3X2IoG5xAw=
=Dfxq
-----END PGP SIGNATURE-----

--ZGiS0Q5IWpPtfppv--
