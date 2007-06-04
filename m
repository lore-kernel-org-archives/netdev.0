From: Maximilian Engelhardt <maxi@daemonizer.de>
Subject: Re: iperf: performance regression (was b44 driver problem?)
Date: Mon, 4 Jun 2007 21:47:59 +0200
Message-ID: <200706042148.02450.maxi@daemonizer.de>
References: <20070525172431.60affaca@freepuppy> <20070604105158.31ede1f5@freepuppy> <20070604193206.GA13271@elte.hu>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1294756.CnZEpMUT4R";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ulrich Drepper <drepper@gmail.com>,
	Michael Buesch <mb@bu3sch.de>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	Gary Zambrano <zambrano@broadcom.com>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from daemonizer.de ([87.230.16.230]:37992 "EHLO daemonizer.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753483AbXFDTsw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2007 15:48:52 -0400
In-Reply-To: <20070604193206.GA13271@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1294756.CnZEpMUT4R
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Monday 04 June 2007, Ingo Molnar wrote:
> * Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> > Yes, the following patch makes iperf work better than ever. But are
> > other broken applications going to have same problem. Sounds like the
> > old "who runs first" fork() problems.
>
> this is the first such app and really, and even for this app: i've been
> frequently running iperf on -rt kernels for _years_ and never noticed
> how buggy its 'locking' code was, and that it would under some
> circumstances use up the whole CPU on high-res timers.

I must admit I don't know much about that topic, but there is one thing I=20
don't understand. Why is iperf (even if it's buggy) able to use up the whol=
e=20
cpu? I didn't run it as root but as my normal user so it should have limite=
d=20
rights. Shouldn't the linux scheduler distribute cpu time among all running=
=20
processes?

Maxi

--nextPart1294756.CnZEpMUT4R
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBGZGxyOimwv528XGERAslBAKDFEN/kVetmUZatC669/yQ+Gds8LQCg0ce3
j/jrso2q5DkyFYTWaCF8fjw=
=e1os
-----END PGP SIGNATURE-----

--nextPart1294756.CnZEpMUT4R--
