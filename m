From: Paul LeoNerd Evans <leonerd@leonerd.org.uk>
Subject: Re: RFC: New BPF 'LOOP' instruction
Date: Tue, 3 Aug 2010 16:27:58 +0100
Message-ID: <20100803152757.GX11110@cel.leo>
References: <20100803070426.GN11110@cel.leo>
 <f350f48de92da479bfb224527bc70c10@chewa.net>
 <20100803141924.GV11110@cel.leo>
 <201008031817.40664.remi@remlab.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="z6iLr+bcE/fwk97b"
To: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont <remi@remlab.net>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cel.leonerd.org.uk ([81.187.167.226]:60256 "EHLO cel.leo"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756293Ab0HCP2A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Aug 2010 11:28:00 -0400
Content-Disposition: inline
In-Reply-To: <201008031817.40664.remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--z6iLr+bcE/fwk97b
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Aug 03, 2010 at 06:17:40PM +0300, R=E9mi Denis-Courmont wrote:
> > And what happens when IPv8 comes along?
> > Or we want to parse IPX/SPX or
> > any of those thousands of other network protocols?
>=20
> It does not work. That's why your SKB_TRANS_OFF proposal sucks totally be=
cause=20
> it is not implementable. On the other hand, n IPv6-specific opcode sucks =
only=20
> a little due to its ugliness and lack of forward compatibility.

Huh? So now you want to make every BPF program IPv6-specific, so we've
no hope in hell of making them cope with The Next Big Thing? As opposed
to my idea, which makes them neutral on the subject, and puts all the
knowledge of the protocol in the -kernel-, where we can easily implement
new things?

When some brandnew protocol comes long we'd like to filter on, kernel is
going to have to know about it. Which is -exactly- the same as the
current situation with regards SKF_NET_OFF / SKF_AD_PROTO, so I don't
really see what difference that makes.

--=20
Paul "LeoNerd" Evans

leonerd@leonerd.org.uk
ICQ# 4135350       |  Registered Linux# 179460
http://www.leonerd.org.uk/

--z6iLr+bcE/fwk97b
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iD8DBQFMWDV9vLS2TC8cBo0RAi9XAJ0fCwU8PPt9IJ7xhOf5Hk1KU+wcOQCg7Sec
itlYS2s5Mc0Tt2MpUyh2L6I=
=hvCX
-----END PGP SIGNATURE-----

--z6iLr+bcE/fwk97b--
