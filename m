From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Bug#645308: tg3 broken for NetXtreme 5714S in squeeze 6.0.3
 installer
Date: Wed, 26 Oct 2011 09:41:44 +0200
Message-ID: <1319614904.11727.17.camel@deadeye>
References: <20111017144825.GM22096@torres.zugschlus.de>
	 <20111017160812.GL3366@decadent.org.uk> <1318901100.3340.36.camel@deadeye>
	 <20111018142056.GF29261@torres.zugschlus.de>
	 <1319084914.23980.96.camel@deadeye>
	 <20111021090046.GA13930@torres.zugschlus.de>
	 <20111021090811.GA5993@torres.zugschlus.de>
	 <1319199579.2918.42.camel@deadeye>
	 <20111024212409.GA29764@mcarlson.broadcom.com>
	 <1319500074.31243.47.camel@deadeye>
	 <20111026002032.GA31575@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ISwZm3Uy+wePZyYl4obH"
Cc: Michael Chan <mchan@broadcom.com>,
	"645308@bugs.debian.org" <645308@bugs.debian.org>,
	Marc Haber <mh+debian-bugs@zugschlus.de>,
	netdev <netdev@vger.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:46062 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932438Ab1JZHmP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2011 03:42:15 -0400
In-Reply-To: <20111026002032.GA31575@mcarlson.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ISwZm3Uy+wePZyYl4obH
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2011-10-25 at 17:20 -0700, Matt Carlson wrote:
> On Mon, Oct 24, 2011 at 04:47:54PM -0700, Ben Hutchings wrote:
> > On Mon, 2011-10-24 at 14:24 -0700, Matt Carlson wrote:
> > > On Fri, Oct 21, 2011 at 05:19:39AM -0700, Ben Hutchings wrote:
> > > > On Fri, 2011-10-21 at 11:08 +0200, Marc Haber wrote:
> > > > > On Fri, Oct 21, 2011 at 11:00:46AM +0200, Marc Haber wrote:
> > > > > > On Thu, Oct 20, 2011 at 05:28:34AM +0100, Ben Hutchings wrote:
> > > > > > > I don't see any changes that would obviously change the way t=
his device
> > > > > > > is reconfigured during a down/up cycle.  There were some chan=
ges to
> > > > > > > power management that should just let the PCI core do some wo=
rk that the
> > > > > > > driver used to, but it's possible that the result isn't quite=
 the same.
> > > > > > > I built a module with those reverted; source and binary attac=
hed.  Could
> > > > > > > you test that?  I checked that d-i does include an insmod com=
mand.
> > > > > >=20
> > > > > > The squeeze 6.0.3 installer with the shipped tg3.ko replaced wi=
th
> > > > > > yours boots and networks just fine without any workaround and w=
ithout
> > > > > > manual interaction.
> > > > >=20
> > > > > I was a bit fast on that. The interface now fails right in the mi=
ddle
> > > > > of installation and needs the modprobe -r, modprobe stunt to netw=
ork
> > > > > again.
> > > >=20
> > > > Matt, Michael,
> > > >=20
> > > > The tg3 driver has regressed for the 5714S since Linux 2.6.32.  Mar=
c
> > > > Haber found this in the backported version included in our stable
> > > > update, but also confirmed it in Linux 3.0.
> > > >=20
> > > > Bringing the interface down and then up again (which the installer =
does
> > > > for some reason) can leave it unable to pass traffic (possibly afte=
r
> > > > working for a few packets) until the module is reloaded.
> > > >=20
> > > > I asked Marc to check whether reverting the power management change=
s
> > > > (071697e2bcd8dff2af4d6fdd6525c2324f89553b,
> > > > d237d9ecf06a00f0ebca657958cf2a1e92940796) made a difference, but it
> > > > doesn't seem to.
> > > >=20
> > > > There is more information in the bug log at
> > > > <http://bugs.debian.org/645308>.
> > >=20
> > > Where can I get the sources for this driver?  Commit
> > > 9e975cc291d80d5e4562d6bed15ec171e896d69b, entitled
> > > "tg3: Fix io failures after chip reset" has been a common source of
> > > problems.
> >=20
> > Our current package has Linux 3.0.6 which includes the backport of that
> > change.  However, it is *not* included in my backport to 2.6.32 so it
> > doesn't explain the original report.
> >=20
> > The backported version can be found in:
> >=20
> > git://anonscm.debian.org/kernel/linux-2.6.git squeeze
>=20
> The kernel version of that repository is 3.0.0-rc1.  Am I looking in the
> right place?

Look at the squeeze branch, not master.

Ben.

> But you're right.  The version of the driver in that repository does not
> have the change.
>=20
>=20

--=20
Ben Hutchings
Reality is just a crutch for people who can't handle science fiction.

--=-ISwZm3Uy+wePZyYl4obH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATqe5uOe/yOyVhhEJAQpLUg//ecKKb9AlgB0UcfeSxfcMcgQgJdrwXpEf
QUxveXnADfkUUF+kbiNTMaGE5hLz00+AkQwYS+cbizdS+DDLP8fpKai63nOxhhRm
9Z4/2hJwiIRoSwhrJL01qkySKJj3ttWA/1pf66maimTkx9366TLhJw3Wl4ej5kMo
+indryeDDpFubgKecN3Ke67U9CFL/BjvuY8otBwxp55UL1zA3J7sgAFXtYTwG/vz
j2f9neaZBLWO0bjQPG/IRsFX0Jmwmo1QKqN5PFrH5OewcA2uKwBaalYOoWK+P1IY
nvURmVWF5+u41CZEIsa7yT2/gG3i6HSh/Rl2RarLIN0CfugGl+ce8/CSyyEqtqeR
tHRQM2IbME55fbXXyV6JxZLgqWtUZ6BIZ4u1seNbSPwH4P+jZaaCcTVUENZ20v6F
Jp8UqvCqznVgTrzaslypO40vDh4avy4xs0/AIR18FrknxkYDK1+GrY4WkbtqEz12
Wq87jfKdMLCK0ksrackEBDFwpjKC7WxbUX0FJROAoOEust0F3fBt5XDeuO/Bm9fD
QmtsTAvbOynAMEk0pS+f+sActYgzV8slFZzWsc6/IzEGqQpx3gW50x5cakizwsh2
11+MM6lzOzBE2ppKTMuwnBA5duIi1ku5qyVHtuthiV3k8KQBPELxWt5dpRTBusrv
EfEyxL+XWjg=
=iUm8
-----END PGP SIGNATURE-----

--=-ISwZm3Uy+wePZyYl4obH--
