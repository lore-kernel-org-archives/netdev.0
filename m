From: Maximilian Engelhardt <maxi@daemonizer.de>
Subject: Re: b44: regression in 2.6.22 (resend)
Date: Sun, 3 Jun 2007 18:26:02 +0200
Message-ID: <200706031826.06891.maxi@daemonizer.de>
References: <20070525172431.60affaca@freepuppy> <200705281944.05030.maxi@daemonizer.de> <1180380230.3657.3.camel@chaos>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2176219.MicN8hRCvA";
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
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755532AbXFCQ1b@vger.kernel.org>
In-Reply-To: <1180380230.3657.3.camel@chaos>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2176219.MicN8hRCvA
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Monday 28 May 2007, Thomas Gleixner wrote:
> On Mon, 2007-05-28 at 19:44 +0200, Maximilian Engelhardt wrote:
> > > Can you please keep CONFIG_HIGH_RES_TIMERS and CONFIG_NOHZ and try the
> > > following combinations on the kernel command line:
> > >
> > > 1) highres=3Doff nohz=3Doff (should be the same as your working confi=
g)
> > > 2) highres=3Doff
> > > 3) nohz=3Doff
> >
> > I tested this with my 2.6.22-rc3 kernel, here are the results:
> >
> > without any special boot parameters: problem does appear
> > highres=3Doff nohz=3Doff: problem does not appear
> > highres=3Doff: problem does not appear
> > nohz=3Doff: problem does appear
>
> Is there any other strange behavior of the high res enabled kernel than
> the b44 problem ?

I didn't notice anything in the past (as I wrote). But today I did some tes=
ts=20
for an updated version of the p54 mac80211 wlan driver and I noticed exactl=
y=20
the same problem:

when booting with highres=3Doff everything is fine.
But when I boot an highres enabled kernel and I do the iperf-test with the =
p54=20
driver, my systems becomes unresponsive during the test. It seems to be=20
exactly the same problem I have with the b44 driver.
So this might not be a bug in the b44 code but a bug somewhere in the linux=
=20
networking code.

I did the test with an 2.6.22-rc3-git4 kernel and the p54 driver built=20
external as module.=20

Maxi

--nextPart2176219.MicN8hRCvA
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBGYuueOimwv528XGERAqZNAJ9jz78DPqrgzhMYyeFI7FAKmsx96QCfULJ3
CWJqCY3C3RIgMcsYRSgz5Q0=
=Fr+1
-----END PGP SIGNATURE-----

--nextPart2176219.MicN8hRCvA--
