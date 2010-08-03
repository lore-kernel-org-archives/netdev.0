From: Paul LeoNerd Evans <leonerd@leonerd.org.uk>
Subject: Re: RFC: New BPF 'LOOP' instruction
Date: Tue, 3 Aug 2010 15:19:24 +0100
Message-ID: <20100803141924.GV11110@cel.leo>
References: <20100803070426.GN11110@cel.leo>
 <20100803.001809.25133218.davem@davemloft.net>
 <87mxt3etut.fsf@basil.nowhere.org>
 <20100803.060754.26959298.davem@davemloft.net>
 <20100803133442.GQ11110@cel.leo>
 <72ff93eb4581b198faa6ce62d2b5162b@chewa.net>
 <20100803141313.GU11110@cel.leo>
 <f350f48de92da479bfb224527bc70c10@chewa.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="0jUhJxQJ3IDt3BFR"
To: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont <remi@remlab.net>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cel.leonerd.org.uk ([81.187.167.226]:42114 "EHLO cel.leo"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755843Ab0HCOTZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Aug 2010 10:19:25 -0400
Content-Disposition: inline
In-Reply-To: <f350f48de92da479bfb224527bc70c10@chewa.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--0jUhJxQJ3IDt3BFR
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Aug 03, 2010 at 04:16:02PM +0200, R=E9mi Denis-Courmont wrote:
> > Is there any way it could be done lazily, at the moment that filter.c
> > knows it has to provide either SKF_TRANS_OFF or SKF_AD_TRANSPROTO?
>=20
> You would essentially need to implement dedicated parsing for each
> protocols family.
> So you might as well add an opcode dedicated to IPv6...

And what happens when IPv8 comes along? Or we want to parse IPX/SPX or
any of those thousands of other network protocols?

I'd prefer to keep the BPF layer (relatively) protocol-neutral. Yes, we
have LDX MSH which with hindsight I'd say looks like a very
protocol-specific instruction. But there's nothing protocol-specific
about asking for where the transport header is and what type it is, no
moreso than asking where the network offset and type are, out of the
link-level header. This just extends that layer model.

How to -implement- it is quite another matter.

--=20
Paul "LeoNerd" Evans

leonerd@leonerd.org.uk
ICQ# 4135350       |  Registered Linux# 179460
http://www.leonerd.org.uk/

--0jUhJxQJ3IDt3BFR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iD8DBQFMWCVsvLS2TC8cBo0RAm/BAKCos/xcepJzLbBqjDSvvDdViV+WWwCaAohf
OkJGuxrqSsP2+Pgv1Zo415A=
=uzDN
-----END PGP SIGNATURE-----

--0jUhJxQJ3IDt3BFR--
