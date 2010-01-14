From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: Can we remove pci_find_device() yet?
Date: Thu, 14 Jan 2010 13:39:15 +0100
Message-ID: <4B4F1073.5060903@imap.cc>
References: <20100108112236.462a3da2.sfr@canb.auug.org.au> <20100108044646.GC6611@suse.de> <4B4B802A.2010709@imap.cc> <20100111200136.GA29955@suse.de> <877hrlf0rf.fsf@basil.nowhere.org> <20100114110214.37d7ffc9@lxorguk.ukuu.org.uk> <20100114110354.GJ12241@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg KH <gregkh@suse.de>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2.smtp.messagingengine.com ([66.111.4.26]:35393 "EHLO
	out2.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755593Ab0ANMvo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2010 07:51:44 -0500
In-Reply-To: <20100114110354.GJ12241@basil.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Am 2010-01-14 12:03 schrieb Andi Kleen:
> On Thu, Jan 14, 2010 at 11:02:14AM +0000, Alan Cox wrote:
[It would be better to enforce this constraint at runtime.]
>> There is a simpler way to do that, which is to just leak a reference=
 in
>> the hisax_find_pci_device hack. The pci_dev won't be going anywhere =
then.
>=20
> You just have to do it once, otherwise it'll fail after 4 billion tim=
es.

I guess we could live with that. pci_find_device() or its successor, th=
e
hisax_find_pci_device() hack, is only called during device setup, once
for most drivers and at the very most 24 times for hfc_pci. Someone
would have to rmmod/insmod a HiSax module more than a hundred million
times to accumulate four billion calls.

- --=20
Tilman Schmidt                    E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=F6ffnet mindestens haltbar bis: (siehe R=FCckseite)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.12 (MingW32)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAktPEHMACgkQQ3+did9BuFuQ/gCgkhu6RJIwrpIDAJMWbO1mZgOd
BKwAnAh6kX5F/+dFPIrK/XLovEAv/R7O
=3DfflE
-----END PGP SIGNATURE-----
