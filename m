From: Jochen Voss <voss@seehuhn.de>
Subject: dead code in tc/m_ematch.c
Date: Sat, 13 Sep 2008 18:58:12 +0100
Message-ID: <20080913175812.GA7365@seehuhn.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="d6Gm4EdcadzBjdND"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from seehuhn.de ([80.68.93.199]:3878 "EHLO seehuhn.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752386AbYIMSeg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2008 14:34:36 -0400
Received: from vburmah.vpn.seehuhn.de ([10.98.27.6] helo=burmah.maths.warwick.ac.uk)
	by seehuhn.de with esmtps (TLS-1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.63)
	(envelope-from <voss@seehuhn.de>)
	id 1KeZNt-0007BK-63
	for netdev@vger.kernel.org; Sat, 13 Sep 2008 18:58:13 +0100
Received: from voss by burmah.maths.warwick.ac.uk with local (Exim 4.69)
	(envelope-from <voss@seehuhn.de>)
	id 1KeZNs-0001uz-Ms
	for netdev@vger.kernel.org; Sat, 13 Sep 2008 18:58:12 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--d6Gm4EdcadzBjdND
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

while looking through the source for the Debian package
iproute-20080725, I found the following bit of code (file
tc/m_ematch.c, lines 163-173):

    static struct ematch_util *get_ematch_kind_num(__u16 kind)
    {
	    char name[32];

	    if (lookup_map(kind, name, sizeof(name), EMATCH_MAP) < 0)
		    return NULL;

	    return get_ematch_kind(name);

	    return NULL;
    }

Obviously the second return statement has no effect.  Probably it
should be removed.

I hope this helps,
Jochen
--=20
http://seehuhn.de/

--d6Gm4EdcadzBjdND
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkjL/zQACgkQf+iD8yEbECX65QCfSxsiA8zyUjIh0Eklj1gXvnYe
/XcAn1uFw0JahAlBf/p46K6siwaWKVDS
=8qI2
-----END PGP SIGNATURE-----

--d6Gm4EdcadzBjdND--
