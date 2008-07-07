From: Mario Limonciello <mario_limonciello@dell.com>
Subject: Re: 8169 Intermittent ifup Failure Issue With RTL8102E Chipset in
 Intel's New D945GCLF Atom Board (Not the Initial Modprobe Crash, Another
 Problem)
Date: Mon, 07 Jul 2008 10:15:00 -0500
Message-ID: <487232F4.6000206@dell.com>
References: <4861800B.90703@nscus.com>	 <20080625213142.GA29890@electric-eye.fr.zoreil.com>	 <48640535.2050000@nscus.com>	 <20080626215918.GC2555@electric-eye.fr.zoreil.com> <1215435236.11909.121.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigBA35A398FFCF885A2AB6202B"
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Michael Grollman <mgrollman@nscus.com>, netdev@vger.kernel.org,
	akpm@linux-foundation.org, linux-pci@vger.kernel.org
To: Kasper Sandberg <lkml@metanurb.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60pc101.us.dell.com ([143.166.85.206]:45651 "EHLO
	ausc60pc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753509AbYGGPPD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 11:15:03 -0400
In-Reply-To: <1215435236.11909.121.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigBA35A398FFCF885A2AB6202B
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

Kasper:

Particularly try the patch that I posted to the list.  It solved the
ifup (and resume) failures for me on two platforms using that chipset.

Regards

Kasper Sandberg wrote:
> On Thu, 2008-06-26 at 23:59 +0200, Francois Romieu wrote:
>  =20
> Sorry for the delay, i had to do an onsite thing in another country, so=

> i first see your message now.
>
> Would it be okay if i took rc9 instead? also, i saw you posted a set of=

> patches to sync more with realteks code, is this something you would
> like me to test too, or aswell? (remember, i have the 8111c).
>
> Btw, a thought just crossed my mind as to a possible reason why this
> might be happening, i was googling around, and it seems the TWO nic's
> are supposed to have some sort of hardware bonding thing, could it be
> because such stuff isnt handled?
>
> mvh.
> Kasper Sandberg
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>  =20

--=20
Mario Limonciello
*Dell | Linux Engineering*
mario_limonciello@dell.com


--------------enigBA35A398FFCF885A2AB6202B
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFIcjL02CrZjkA73YsRAqGfAKCOpuJ231i9Pana31SwgLGHvZ9x4ACeJN54
GY40X01YXtUuBWa8L1VY0zo=
=iVw2
-----END PGP SIGNATURE-----

--------------enigBA35A398FFCF885A2AB6202B--
