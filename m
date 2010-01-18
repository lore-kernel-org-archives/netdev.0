From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: linux-next build failure (was: Re: [PATCH/REPOST] pci: push deprecated
 pci_find_device() function to last user)
Date: Mon, 18 Jan 2010 16:46:00 +0100
Message-ID: <4B548238.9080008@imap.cc>
References: <10f740e81001180644yd44121cv6dd963349563a290@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig8B6F6B46BA13FB05BA6FA36D"
Cc: Jesse Barnes <jbarnes@virtuousgeek.org>,
	David Miller <davem@davemloft.net>, Greg KH <gregkh@suse.de>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2.smtp.messagingengine.com ([66.111.4.26]:39107 "EHLO
	out2.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754075Ab0ARPxU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2010 10:53:20 -0500
In-Reply-To: <10f740e81001180644yd44121cv6dd963349563a290@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig8B6F6B46BA13FB05BA6FA36D
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Am 18.01.2010 15:44 schrieb Geert Uytterhoeven:
> On Fri, Jan 15, 2010 at 19:08, Jesse Barnes <jbarnes@virtuousgeek.org> =
wrote:
>> On Thu, 14 Jan 2010 23:18:41 +0100 (CET)
>> Tilman Schmidt <tilman@imap.cc> wrote:
>>>
>>> Subject: [PATCH] pci: push deprecated pci_find_device() function to
>>> last user
>>>
>>> The ISDN4Linux HiSax driver family contains the last remaining users
>>> of the deprecated pci_find_device() function. This patch creates a
>>> private copy of that function in HiSax, and removes the now unused
>>> global function together with its controlling configuration option,
>>> CONFIG_PCI_LEGACY.
>>>
>>> Impact: code reorganization, no functional change
>>> Signed-off-by: Tilman Schmidt <tilman@imap.cc>
>>> ---
>>> Note: This patch is not, nor does it intend to be, checkpatch.pl
>>> clean. The issues checkpatch.pl reports on it were already present
>>> before, and are unrelated to the topic of this patch.
>>
>> Applied to my linux-next branch, thanks Tilman.
>=20
> Just guessing: something's wrong if CONFIG_PCI is not set?
>=20
> http://kisskb.ellerman.id.au/kisskb/buildresult/2042085/

Sorry, oversight of mine. I thought that hisax/avm_pci.c depended on
CONFIG_PCI, but it doesn't, as it also handles ISA PnP cards. I will
issue a corrected patch ASAP.

Thanks,
Tilman

--=20
Tilman Schmidt                    E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=C3=B6ffnet mindestens haltbar bis: (siehe R=C3=BCckseite)


--------------enig8B6F6B46BA13FB05BA6FA36D
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.12 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org/

iEYEARECAAYFAktUgkIACgkQQ3+did9BuFvLhgCdFlr0VFSqbRUdSFpn5zHWu6gt
1U0An0qs6CXr/zChybVdaA42sdnaRzuu
=jS+8
-----END PGP SIGNATURE-----

--------------enig8B6F6B46BA13FB05BA6FA36D--
