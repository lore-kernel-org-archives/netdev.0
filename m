From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: Can we remove pci_find_device() yet?
Date: Tue, 12 Jan 2010 11:21:15 +1100
Message-ID: <20100112112115.98009d50.sfr@canb.auug.org.au>
References: <20100108112236.462a3da2.sfr@canb.auug.org.au>
	<20100108044646.GC6611@suse.de>
	<4B4B802A.2010709@imap.cc>
	<20100111200136.GA29955@suse.de>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__12_Jan_2010_11_21_15_+1100_wPfjVLs1zsoYD1mn"
Cc: Tilman Schmidt <tilman@imap.cc>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: Greg KH <gregkh@suse.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754302Ab0ALAV1@vger.kernel.org>
In-Reply-To: <20100111200136.GA29955@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__12_Jan_2010_11_21_15_+1100_wPfjVLs1zsoYD1mn
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Greg,

On Mon, 11 Jan 2010 12:01:36 -0800 Greg KH <gregkh@suse.de> wrote:
>
> Close, but if you do this, please name the function
> hisax_find_pci_device() or something, and change the drivers to use it
> instead.  Also put a big fat warning in the function that calling this
> is unsafe for any PCI hotplug type machine.

There is another implementation of pci_find_device in
drivers/staging/dt3155/pci-compat.h (used by dt3155_drv.c).
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__12_Jan_2010_11_21_15_+1100_wPfjVLs1zsoYD1mn
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAktLwHwACgkQjjKRsyhoI8zRiACfR+S4tL9GTzsSUPl9trNgRAfE
BZYAn2oluFkU/kwDvE0CQZK3mqriNyML
=lmE1
-----END PGP SIGNATURE-----

--Signature=_Tue__12_Jan_2010_11_21_15_+1100_wPfjVLs1zsoYD1mn--
