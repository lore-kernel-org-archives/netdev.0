From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [PATCH 1/2] gigaset: return -ENOSYS for unimplemented functions
Date: Sun, 08 Mar 2009 01:22:28 +0100
Message-ID: <49B30FC4.5040305@imap.cc>
References: <20090307-patch-00.tilman@imap.cc>	<20090307-patch-01.tilman@imap.cc> <20090307142609.2995bb3d@infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig87C33221364751EA02A0FE96"
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Paul Bolle <pebolle@tiscali.nl>,
	Hansjoerg Lipp <hjlipp@web.de>
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1.smtp.messagingengine.com ([66.111.4.25]:54727 "EHLO
	out1.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752270AbZCHAWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2009 19:22:47 -0500
In-Reply-To: <20090307142609.2995bb3d@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig87C33221364751EA02A0FE96
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Am 07.03.2009 23:26 schrieb Arjan van de Ven:
> On Sat,  7 Mar 2009 23:10:57 +0100 (CET)
> Tilman Schmidt <tilman@imap.cc> wrote:
>=20
>> From: Paul Bolle <pebolle@tiscali.nl>
>>
>> A number of functions in the usb_gigaset module will return -EINVAL if=

>> CONFIG_GIGASET_UNDOCREQ is not set. Make these return -ENOSYS as it's
>> more specific and it might make it easier to see (from userspace) why
>> these functions actually fail.
>>
>> Impact: some error return codes changed
>=20
> ENODEV is what would be more appropriate.

Not at all. ENODEV means "no such device", which would be quite wrong.
The device does exist and is in all probability working perfectly fine.
It just doesn't implement that particular ioctl.

> ENOSYS shuoldn't be returned from drivers, only from unimplemented
> system calls!

There's precedent for using ENOSYS for that case, for example in
drivers/char/vt_ioctl.c. But I'm open for other suggestions.

Thanks,
Tilman

--=20
Tilman Schmidt                    E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=F6ffnet mindestens haltbar bis: (siehe R=FCckseite)


--------------enig87C33221364751EA02A0FE96
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.4-svn0 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iD8DBQFJsw/RQ3+did9BuFsRAo42AJ9hA8aQThdvXGByEgYGuCuZheYifwCfRFon
dUO+CM+yWPAKt1mJd30K89w=
=bnBE
-----END PGP SIGNATURE-----

--------------enig87C33221364751EA02A0FE96--
