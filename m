From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: Can we remove pci_find_device() yet?
Date: Tue, 12 Jan 2010 17:42:14 +0100
Message-ID: <4B4CA666.1050505@imap.cc>
References: <20100108112236.462a3da2.sfr@canb.auug.org.au> <20100108044646.GC6611@suse.de> <4B4B802A.2010709@imap.cc> <20100111200136.GA29955@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1.smtp.messagingengine.com ([66.111.4.25]:53449 "EHLO
	out1.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753649Ab0ALR1s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 12:27:48 -0500
In-Reply-To: <20100111200136.GA29955@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Am 2010-01-11 21:01 schrieb Greg KH:
> On Mon, Jan 11, 2010 at 08:46:50PM +0100, Tilman Schmidt wrote:
>>
>> Just an idea - as a stopgap measure, couldn't pci_find_device() be m=
ade
>> a private function of the HiSax drivers? That way, the remainder of =
the
>> kernel won't be polluted by it anymore, and the PCI_LEGACY config op=
tion
>> can be dropped. Something like this quick and dirty hack:
>=20
> Close, but if you do this, please name the function
> hisax_find_pci_device() or something, and change the drivers to use i=
t

Sorry, but no. That would drag me into the checkpatch.pl swamp,
a place I know well enough by now to avoid it whenever possible.
Many of the calls to pci_find_device() have checkpatch problems
which of course do not go away by just substituting another
function name, so I would be obliged to restructure all those
call sites by hand for the sake of "not introducing new code
with checkpatch problems". BTDT.

So I'll drop that idea. If someone else wants to pick it up,
feel free to do so.

Regards,
Tilman

- --=20
Tilman Schmidt                    E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=F6ffnet mindestens haltbar bis: (siehe R=FCckseite)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.12 (MingW32)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAktMpmYACgkQQ3+did9BuFuJKgCggRImZ3NOTmCJUpUktreervtz
fegAniAexJirz3p/AXPB6EpsCEJn3hPL
=3DQwUB
-----END PGP SIGNATURE-----
