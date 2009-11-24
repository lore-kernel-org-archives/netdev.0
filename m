From: Alex Samad <alex@samad.com.au>
Subject: Re: icmp redirects problem
Date: Tue, 24 Nov 2009 11:12:30 +1100
Message-ID: <20091124001230.GC14245@samad.com.au>
References: <20091123043124.GA14795@samad.com.au>
 <4B0B058E.3050906@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="u3/rZRmxL6MmkK24"
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail13.tpgi.com.au ([203.12.160.181]:33188 "EHLO
	mail13.tpgi.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752187AbZKXAMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 19:12:31 -0500
Content-Disposition: inline
In-Reply-To: <4B0B058E.3050906@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--u3/rZRmxL6MmkK24
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Nov 23, 2009 at 10:58:38PM +0100, Jarek Poplawski wrote:
> Alex Samad wrote, On 11/23/2009 05:31 AM:
>=20

[snip]

> >=20
> > laptop gets its ip from dchp server that make 192.168.11.1 the default
> > gateway and its 192.168.11.1 that sends out the icmp redirect.
>=20
> Btw, it seems you should fix your routing (by adding sydrt01's eth0
> the second ip or advertising 192.168.11.10 more) to avoid those
> redirects.

sorry I am lost on this statement, I can't add 192.168.11.10 to sydrt01
as it is not physically connected to the 192.168.10.0/24 any more, which
is why I had added the route on sydrt01 and which is why it send
icmp_rediercts.

I have updated the route table on each static machine, but the problem
is on the machines that get their ip via dhcp - I haven't looked at
pushing out route information via dhcp - I am not sure that it would
work in a mixed windows / linux environment.

what do you mean by advertising 192.168.11.10 more ?

>=20
> >=20
> > I had a quick look at the kernel tree for 2.6.31 (which is what I am
> > using).
>=20
> ...
>=20
> > Line 680
> >  secure_redirects - BOOLEAN
> >  681         Accept ICMP redirect messages only for gateways,
> >  682         listed in default gateway list.
> >  683         secure_redirects for the interface will be enabled if at
> >  least one of
> >  684         conf/{all,interface}/secure_redirects is set to TRUE,
> >  685         it will be disabled otherwise
> >  686         default TRUE
>=20
> Very helpful links. So, as you wrote "the documentation seems to suggest"
> something, and IMHO even if it doesn't, it's needlessly too concise
> considering your "lost time", and I'd suggest you sending a patch to fix
> this. (It seems it could "touch" shared_media, as well.)

Which is wrong the code or the documentation and which part the test or
the reliance on the shared_media or on the redirects flags



>=20
> Thanks,
> Jarek P.
>=20


--u3/rZRmxL6MmkK24
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAksLJOoACgkQkZz88chpJ2NqvQCdHqwwT6WRoBL+2fO8tRo51BYR
+NoAoM69ylCuw0P8f9OtWAWRU9Q1ivpD
=OM4U
-----END PGP SIGNATURE-----

--u3/rZRmxL6MmkK24--
