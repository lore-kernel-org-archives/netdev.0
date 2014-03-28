From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [PATCH 1/7] isdn: replace del_timer by del_timer_sync
Date: Sat, 29 Mar 2014 00:19:47 +0100
Message-ID: <53360393.2030108@imap.cc>
References: <1395869625-15209-1-git-send-email-Julia.Lawall@lip6.fr> <1395869625-15209-2-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Karsten Keil <isdn@linux-pingi.de>, tglx@linutronix.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Julia Lawall <Julia.Lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395869625-15209-2-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Am 26.03.2014 22:33, schrieb Julia Lawall:
> From: Julia Lawall <Julia.Lawall@lip6.fr>
>=20
> Use del_timer_sync to ensure that the timer is stopped on all CPUs
> before the driver exists.

Surely you meant "exits"?

Regards,
Tilman

- --=20
Tilman Schmidt                              E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=F6ffnet mindestens haltbar bis: (siehe R=FCckseite)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (MingW32)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlM2A5IACgkQQ3+did9BuFtuMACfarliJdOkqLmJJvRqbcM5eCFd
CWwAn3FuQ+juOeo2EgM8e1JBTjlHhG3o
=3Da90K
-----END PGP SIGNATURE-----
