From: Paul LeoNerd Evans <leonerd@leonerd.org.uk>
Subject: Re: RFC: New BPF 'LOOP' instruction
Date: Tue, 3 Aug 2010 14:42:31 +0100
Message-ID: <20100803134231.GS11110@cel.leo>
References: <20100803070426.GN11110@cel.leo>
 <20100803.001809.25133218.davem@davemloft.net>
 <87mxt3etut.fsf@basil.nowhere.org>
 <20100803.060754.26959298.davem@davemloft.net>
 <20100803133442.GQ11110@cel.leo>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="dUCTBDm4d+mXXNar"
Cc: andi@firstfloor.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cel.leonerd.org.uk ([81.187.167.226]:41159 "EHLO cel.leo"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756379Ab0HCNmc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Aug 2010 09:42:32 -0400
Content-Disposition: inline
In-Reply-To: <20100803133442.GQ11110@cel.leo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--dUCTBDm4d+mXXNar
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Aug 03, 2010 at 02:34:43PM +0100, Paul LeoNerd Evans wrote:
>     LD BYTE[SKF_NET_OFF+0]
>     JEQ 80, #accept, 0
>     LD BYTE[SKF_NET_OFF+2]
>     JEQ 80, 0, #reject

My apologies; theabove should be "LD HALF" instructions; TCP ports are
16 bit quantities. Hopefully this mistake does not detract from my
argument...

--=20
Paul "LeoNerd" Evans

leonerd@leonerd.org.uk
ICQ# 4135350       |  Registered Linux# 179460
http://www.leonerd.org.uk/

--dUCTBDm4d+mXXNar
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iD8DBQFMWBzHvLS2TC8cBo0RAoN+AJ4m7yfS7wf5gJAiwvhbmWQZYRU7OACeLNYV
wra2HYsAXuVAz0Y5a2idVyU=
=uqgf
-----END PGP SIGNATURE-----

--dUCTBDm4d+mXXNar--
