From: Paul LeoNerd Evans <leonerd@leonerd.org.uk>
Subject: Re: RFC: New BPF 'LOOP' instruction
Date: Tue, 3 Aug 2010 15:13:13 +0100
Message-ID: <20100803141313.GU11110@cel.leo>
References: <20100803070426.GN11110@cel.leo>
 <20100803.001809.25133218.davem@davemloft.net>
 <87mxt3etut.fsf@basil.nowhere.org>
 <20100803.060754.26959298.davem@davemloft.net>
 <20100803133442.GQ11110@cel.leo>
 <72ff93eb4581b198faa6ce62d2b5162b@chewa.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="qgeIJYx8sDYEmUhr"
To: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont <remi@remlab.net>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cel.leonerd.org.uk ([81.187.167.226]:33557 "EHLO cel.leo"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755969Ab0HCONP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Aug 2010 10:13:15 -0400
Content-Disposition: inline
In-Reply-To: <72ff93eb4581b198faa6ce62d2b5162b@chewa.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--qgeIJYx8sDYEmUhr
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Aug 03, 2010 at 04:09:53PM +0200, R=E9mi Denis-Courmont wrote:
>=20
> On Tue, 3 Aug 2010 14:34:43 +0100, Paul LeoNerd Evans
> <leonerd@leonerd.org.uk> wrote:
> > What if we added a new constant SKF_TRANS_OFF to store the start address
> > of the transport header, and a new SKF_AD storage area for the transport
> > protocol:
> (...)
> > Does this sound workable?
>=20
> The network header has not been processed by the time the skbuff hits the
> packet socket. So the transport header offset is not defined yet.

Is there any way it could be done lazily, at the moment that filter.c
knows it has to provide either SKF_TRANS_OFF or SKF_AD_TRANSPROTO? It
doesn't even need to do a full parse, just enough to find the length and
protocol type.

That processing -has- to be done one way or another, if BPF is ever to
support filtering on TCP headers in IPv6 in a sane way. Either encode
the algorithm in BPF, or in compiled C code - the latter would be more
performant.

--=20
Paul "LeoNerd" Evans

leonerd@leonerd.org.uk
ICQ# 4135350       |  Registered Linux# 179460
http://www.leonerd.org.uk/

--qgeIJYx8sDYEmUhr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iD8DBQFMWCP5vLS2TC8cBo0RAsprAKDqY4tabvGiNUCfFLUD2pmM99jV/QCg+IOW
Tbvz42GoZl8et1js74Us4wQ=
=Y5Gh
-----END PGP SIGNATURE-----

--qgeIJYx8sDYEmUhr--
