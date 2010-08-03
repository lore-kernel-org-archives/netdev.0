From: Paul LeoNerd Evans <leonerd@leonerd.org.uk>
Subject: Re: RFC: New BGF 'LOOP' instruction
Date: Tue, 3 Aug 2010 08:07:10 +0100
Message-ID: <20100803070709.GO11110@cel.leo>
References: <20100802110334.GK11110@cel.leo>
 <20100802201629.GA5973@nuttenaction>
 <20100802.221813.43045517.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="SIAOfPybDqHGMRuo"
Cc: hagen@jauu.net
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cel.leonerd.org.uk ([81.187.167.226]:36711 "EHLO cel.leo"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755229Ab0HCHHM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Aug 2010 03:07:12 -0400
Content-Disposition: inline
In-Reply-To: <20100802.221813.43045517.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--SIAOfPybDqHGMRuo
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Aug 02, 2010 at 10:18:13PM -0700, David Miller wrote:
> If you just check for a single loop hitting, the user will just use
> a chaining of two looping constructs.  And then three levels of
> indirection, then four, etc.  He can run up to just before exhasting
> the "iteration limit" of one loop, and branch to the next one, and
> so on and so forth.

And this is why part of my suggestion bans the use of a LOOP
instruction within the "body" of another, such that they cannot nest.

> There are probably a million ways to exploit this, and once you come
> up with a validation or limiting scheme one of two things will happen:
>=20
> 1) The limiting scheme will make legitimate scripts USELESS

Rightnow, BPF is all but useless for parsing, say, IPv6. I only pick
IPv6 as one example, I'm sure there must exist a great number more
packet-based protocols that use a "linked-list" style approach to
headers. None of those are currently filterable on the current set of
instructions. LOOP would allow these.

--=20
Paul "LeoNerd" Evans

leonerd@leonerd.org.uk
ICQ# 4135350       |  Registered Linux# 179460
http://www.leonerd.org.uk/

--SIAOfPybDqHGMRuo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iD8DBQFMV8AdvLS2TC8cBo0RAqgmAJ9SkU1H7qmYPMrI8l1/KuD69rGEYwCdH5+B
gMdsWuW5uGU2r1riv8XRUBE=
=Qr5G
-----END PGP SIGNATURE-----

--SIAOfPybDqHGMRuo--
