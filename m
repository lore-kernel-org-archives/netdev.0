From: Maximilian Engelhardt <maxi@daemonizer.de>
Subject: Re: b44: regression in 2.6.22 (resend)
Date: Mon, 28 May 2007 19:44:01 +0200
Message-ID: <200705281944.05030.maxi@daemonizer.de>
References: <20070525172431.60affaca@freepuppy> <200705281714.25841.mb@bu3sch.de> <1180366371.4952.5.camel@chaos>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2287403.tJeXkTR7z7";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	Gary Zambrano <zambrano@broadcom.com>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from daemonizer.de ([87.230.16.230]:37820 "EHLO daemonizer.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750746AbXE1Rot (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 May 2007 13:44:49 -0400
In-Reply-To: <1180366371.4952.5.camel@chaos>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2287403.tJeXkTR7z7
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Monday 28 May 2007, Thomas Gleixner wrote:
> On Mon, 2007-05-28 at 17:14 +0200, Michael Buesch wrote:
> > > The -oldconfig1 is the kernel that had no problems and the other shows
> > > the b44 problem. So if High Resolution Timer Support is disabled
> > > everything works fine and if I enable it the problems do appear again.
> > >
> > > I didn't test this on my 2.6.22-rc3 kernel yet, but I guess disabling
> > > High Resolution Timer Support will also solve the problem there.
> > >
> > > The older kernels I tried also work perfectly fine and they didn't ha=
ve
> > > the High Resolution Timer Support yet.
> >
> > So, that's interesting, indeed.
> > Any idea what's going on, someone? Thomas?
>
> Not off the top of my head.
>
> Maximilian, does the kernel work otherwise (I mean aside of the b44
> driver) ?
>
> Can you please keep CONFIG_HIGH_RES_TIMERS and CONFIG_NOHZ and try the
> following combinations on the kernel command line:
>
> 1) highres=3Doff nohz=3Doff (should be the same as your working config)
> 2) highres=3Doff
> 3) nohz=3Doff

I tested this with my 2.6.22-rc3 kernel, here are the results:

without any special boot parameters: problem does appear
highres=3Doff nohz=3Doff: problem does not appear
highres=3Doff: problem does not appear
nohz=3Doff: problem does appear

I additionally built my 2.6.22-rc2-mm1 kernel without High Resolution Timer=
,=20
but the high ping problem is still there.

Maxi

--nextPart2287403.tJeXkTR7z7
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBGWxTkOimwv528XGERAp5/AKCCdq62kkUKbc5uWKYSrL0gqbrNKQCfQjaB
JH739BP9ISBeu38nePZD7TU=
=/pIt
-----END PGP SIGNATURE-----

--nextPart2287403.tJeXkTR7z7--
