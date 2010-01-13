From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: Can we remove pci_find_device() yet?
Date: Wed, 13 Jan 2010 10:02:28 +0100
Message-ID: <4B4D8C24.6060007@imap.cc>
References: <20100108112236.462a3da2.sfr@canb.auug.org.au> <20100108044646.GC6611@suse.de> <4B4B802A.2010709@imap.cc> <20100111200136.GA29955@suse.de> <4B4CA666.1050505@imap.cc> <20100112173947.GA7784@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: Greg KH <gregkh@suse.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755176Ab0AMJCe@vger.kernel.org>
In-Reply-To: <20100112173947.GA7784@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Am 2010-01-12 18:39 schrieb Greg KH:
> On Tue, Jan 12, 2010 at 05:42:14PM +0100, Tilman Schmidt wrote:
[...]
>> Many of the calls to pci_find_device() have checkpatch problems
>> which of course do not go away by just substituting another
>> function name, so I would be obliged to restructure all those
>> call sites by hand for the sake of "not introducing new code
>> with checkpatch problems". BTDT.
>=20
> No you would not, don't be crazy.  Modfying a single line to rename a
> function from one thing to another could never be decreed as a "don't
> add bad code".  And if someone says it is, well, you just found someo=
ne
> who doesn't know what they are doing :)

Ok. I do hope you are right, and my extrapolation from past
experience was wrong.

> Please continue with this idea, it's sane, and valid.

Alright, will do. Patch will follow later today, SCJ. Let's see
what the checkpatch police will say.

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

iEYEARECAAYFAktNjCQACgkQQ3+did9BuFsmMwCfReQ/mHQUApkpRWJZIG16PmvI
vO4Anj/A4kSwddg+RZV2Uj5LVUNlsBD3
=3DLxhW
-----END PGP SIGNATURE-----
