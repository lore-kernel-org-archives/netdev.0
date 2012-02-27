From: Valdis.Kletnieks@vt.edu
Subject: Re: [PATCHv3 2/3] NETKGDB: Ethernet/UDP/IP KDB transport.
Date: Mon, 27 Feb 2012 00:29:03 -0500
Message-ID: <116798.1330320543@turing-police.cc.vt.edu>
References: <1330137851-4716-1-git-send-email-andrey.warkentin@gmail.com> <1330313411-845-1-git-send-email-andrey.warkentin@gmail.com>
            <1330313411-845-3-git-send-email-andrey.warkentin@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1330320543_6549P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andrei Warkentin <andreiw@vmware.com>,
	kgdb-bugreport@lists.sourceforge.net,
	Jason Wessel <jason.wessel@windriver.com>,
	Matt Mackall <mpm@selenic.com>
To: Andrei Warkentin <andrey.warkentin@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: Your message of "Sun, 26 Feb 2012 22:30:10 EST."
             <1330313411-845-3-git-send-email-andrey.warkentin@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1330320543_6549P
Content-Type: text/plain; charset=us-ascii

On Sun, 26 Feb 2012 22:30:10 EST, Andrei Warkentin said:

> +Note: the parameter is optional and largely unneeded unless you
> +are running a listen server - netkgdb will accept connection from any
> +IP on all interfaces and will reconfigure itself appropriately if

This *really* needs a discussion of the security implications of this.  Do
you *really* want to have a kgdb that will accept connections from *anywhere*?
Sounds like an insta-root waiting to happen.

> +the assigned interface IP address changes. This makes it useful
> +in an environment where it's not known ahead of time what computer
> +will connect to perform the crash analysis.

Exactly. You don't know ahead of time who's going to connect. That's the
problem...

--==_Exmh_1330320543_6549P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBT0sUnwdmEQWDXROgAQKSkw//Xbl4nTmDtTxYA9sgOvDw8O35P1ytSN/p
uNkUVQ2ry8ash091BM/bfkEVd8qa8cgW+cAliw3lOd7Uke2Vsp5xQNFMHD6Divtx
hOhBOHO6lVQyAKtuf9HFxX2HtMzEQeuv2e4jzOp0kMcWLfg6R12FzPeQElFZph7V
/Tg2n4ICYSR4TGewNOCVkYUNHzwLoWbVw4AMcE6hFvp1RlahOqMuLrDyvgU2Rmj5
vVOrID50jDRYlrB7qNwMBLRYEMgIrojeWqXZ3u34NiM7BGQCIdZwrzvbTpChAN4S
DXlPjOy8dhT1CF1xuSWctNl5pnAn69F4NkSKoIoskrs3X8c+M5LRSYhp87q7oiVE
82qq4WcUu5TbNhepjGvvJrq4fJ91UDy5uV71BarJnGM0QZLgLK23l8+XMUsvQ2Wl
Xe2F9Y01mk0+x3/yis0KlFgnMePiYEKzUFey2B1pWCLp1yZzMvDe3NtHIXlXqbiu
Jta9AyiO4m9sDP1InLspmte0mjH1LuwmhsN6HRroB7Umv2De7H1Fr8/dwSzjLwF0
YaioG4vuoPMAIV6y2WpJYSkbH+Dt2HN7dNoFcavTCqFJEkFIFZURRQcMCCxPbn3j
T5QsZb0gOVol9fAFZy1UznBlBj2Sg7g/3ppgagQbb1Kj0wdM3OBkVN9L5Ench2Nj
VfuLu2iTzfs=
=7WKG
-----END PGP SIGNATURE-----

--==_Exmh_1330320543_6549P--
