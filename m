From: Paul LeoNerd Evans <leonerd@leonerd.org.uk>
Subject: Re: RFC: New BGF 'LOOP' instruction
Date: Tue, 3 Aug 2010 08:04:27 +0100
Message-ID: <20100803070426.GN11110@cel.leo>
References: <20100802110334.GK11110@cel.leo>
 <20100802.221341.137851732.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="uaevfG5uZ9KhizUI"
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cel.leonerd.org.uk ([81.187.167.226]:36707 "EHLO cel.leo"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755229Ab0HCHE3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Aug 2010 03:04:29 -0400
Content-Disposition: inline
In-Reply-To: <20100802.221341.137851732.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--uaevfG5uZ9KhizUI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Aug 02, 2010 at 10:13:41PM -0700, David Miller wrote:
> > Any comments on this, while I proceed? Barring any major complaints,
> > I'll have a hack at some code and present a patch in due course...
>=20
> We're not adding loop instructions, it's just asking for trouble
> since any user can attach BPF filters to a socket and it's just
> way too easy to make a loop endless.
>=20
> There's a reason no loop primitives were added to the original
> BPF specification, perhaps you should take a look at what their
> reasoning was.

Yes. I am very aware of that.

Please read carefully my suggestion. These loops cannot be made endless
- they will be bounded by, at most, the number of bytes in the packet
buffer. The loop is required to increment X at least 1 at every
iteration, and will not allow it to continue past the end of the packet.
This puts a strict bound on the runtime of the loop.

--=20
Paul "LeoNerd" Evans

leonerd@leonerd.org.uk
ICQ# 4135350       |  Registered Linux# 179460
http://www.leonerd.org.uk/

--uaevfG5uZ9KhizUI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iD8DBQFMV796vLS2TC8cBo0RAhVMAKD62AXaye3Z4sYalfzh89EOs0sjfwCfRgPn
h5fWJVsPVPlFp1If4e6kXwE=
=yfKt
-----END PGP SIGNATURE-----

--uaevfG5uZ9KhizUI--
