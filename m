From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 1/7] isdn: replace del_timer by del_timer_sync
Date: Sat, 29 Mar 2014 07:28:22 +0100 (CET)
Message-ID: <alpine.DEB.2.02.1403290728100.2480@localhost6.localdomain6>
References: <1395869625-15209-1-git-send-email-Julia.Lawall@lip6.fr> <1395869625-15209-2-git-send-email-Julia.Lawall@lip6.fr> <53360393.2030108@imap.cc>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-1288733107-1396074505=:2480"
Cc: Julia Lawall <Julia.Lawall@lip6.fr>,
	Karsten Keil <isdn@linux-pingi.de>, tglx@linutronix.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53360393.2030108@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-1288733107-1396074505=:2480
Content-Type: TEXT/PLAIN; charset=iso-8859-15
Content-Transfer-Encoding: 8BIT



On Sat, 29 Mar 2014, Tilman Schmidt wrote:

> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> Am 26.03.2014 22:33, schrieb Julia Lawall:
> > From: Julia Lawall <Julia.Lawall@lip6.fr>
> > 
> > Use del_timer_sync to ensure that the timer is stopped on all CPUs
> > before the driver exists.
> 
> Surely you meant "exits"?

Yes.

julia

> 
> Regards,
> Tilman
> 
> - -- 
> Tilman Schmidt                              E-Mail: tilman@imap.cc
> Bonn, Germany
> Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
> Ungeöffnet mindestens haltbar bis: (siehe Rückseite)
> -----BEGIN PGP SIGNATURE-----
> Version: GnuPG v2.0.22 (MingW32)
> Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/
> 
> iEYEARECAAYFAlM2A5IACgkQQ3+did9BuFtuMACfarliJdOkqLmJJvRqbcM5eCFd
> CWwAn3FuQ+juOeo2EgM8e1JBTjlHhG3o
> =a90K
> -----END PGP SIGNATURE-----
> 
--8323328-1288733107-1396074505=:2480--
