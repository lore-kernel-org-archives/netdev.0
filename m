From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [PATCH 1/2] gigaset: return -ENOSYS for unimplemented functions
Date: Sun, 08 Mar 2009 13:26:35 +0100
Message-ID: <49B3B97B.5090308@imap.cc>
References: <20090307-patch-00.tilman@imap.cc>	<20090307-patch-01.tilman@imap.cc>	<20090307142609.2995bb3d@infradead.org>	<49B30FC4.5040305@imap.cc>	<20090307163522.1165494b@infradead.org>	<49B3176A.7000004@imap.cc> <20090307173819.36d352c8@infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig40F7EB796403E0284CD5E062"
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Paul Bolle <pebolle@tiscali.nl>,
	Hansjoerg Lipp <hjlipp@web.de>
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2.smtp.messagingengine.com ([66.111.4.26]:41215 "EHLO
	out2.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751256AbZCHM1I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Mar 2009 08:27:08 -0400
In-Reply-To: <20090307173819.36d352c8@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig40F7EB796403E0284CD5E062
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Am 08.03.2009 02:38 schrieb Arjan van de Ven:
> from the ioctl manpage:
>=20
> ERRORS
> 	[snip]
>=20
>        ENOTTY The specified request does not apply to the kind of
>        object that the descriptor d references.

Ok, I'm convinced. I'll redo the patch with ENOTTY instead of ENOSYS.

Thanks,
Tilman

--=20
Tilman Schmidt                    E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=F6ffnet mindestens haltbar bis: (siehe R=FCckseite)


--------------enig40F7EB796403E0284CD5E062
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.4-svn0 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iD8DBQFJs7mSQ3+did9BuFsRAsXxAJ9CLmk6MvK7v9kU1MLf1ihqIAoGDgCfbK5p
5R6NfmJYTYjA5i9j+mEUBI8=
=TRh8
-----END PGP SIGNATURE-----

--------------enig40F7EB796403E0284CD5E062--
