From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Bug#645308: tg3 broken for NetXtreme 5714S in squeeze 6.0.3
 installer
Date: Tue, 25 Oct 2011 01:47:54 +0200
Message-ID: <1319500074.31243.47.camel@deadeye>
References: <20111017135457.GL22096@torres.zugschlus.de>
	 <1318861800.3340.21.camel@deadeye>
	 <20111017144825.GM22096@torres.zugschlus.de>
	 <20111017160812.GL3366@decadent.org.uk> <1318901100.3340.36.camel@deadeye>
	 <20111018142056.GF29261@torres.zugschlus.de>
	 <1319084914.23980.96.camel@deadeye>
	 <20111021090046.GA13930@torres.zugschlus.de>
	 <20111021090811.GA5993@torres.zugschlus.de>
	 <1319199579.2918.42.camel@deadeye>
	 <20111024212409.GA29764@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-YNmjl9Zl/yEwb6KNMGiB"
Cc: Michael Chan <mchan@broadcom.com>,
	"645308@bugs.debian.org" <645308@bugs.debian.org>,
	Marc Haber <mh+debian-bugs@zugschlus.de>,
	netdev <netdev@vger.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:60899 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755493Ab1JXXsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2011 19:48:19 -0400
In-Reply-To: <20111024212409.GA29764@mcarlson.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-YNmjl9Zl/yEwb6KNMGiB
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2011-10-24 at 14:24 -0700, Matt Carlson wrote:
> On Fri, Oct 21, 2011 at 05:19:39AM -0700, Ben Hutchings wrote:
> > On Fri, 2011-10-21 at 11:08 +0200, Marc Haber wrote:
> > > On Fri, Oct 21, 2011 at 11:00:46AM +0200, Marc Haber wrote:
> > > > On Thu, Oct 20, 2011 at 05:28:34AM +0100, Ben Hutchings wrote:
> > > > > I don't see any changes that would obviously change the way this =
device
> > > > > is reconfigured during a down/up cycle.  There were some changes =
to
> > > > > power management that should just let the PCI core do some work t=
hat the
> > > > > driver used to, but it's possible that the result isn't quite the=
 same.
> > > > > I built a module with those reverted; source and binary attached.=
  Could
> > > > > you test that?  I checked that d-i does include an insmod command=
.
> > > >=20
> > > > The squeeze 6.0.3 installer with the shipped tg3.ko replaced with
> > > > yours boots and networks just fine without any workaround and witho=
ut
> > > > manual interaction.
> > >=20
> > > I was a bit fast on that. The interface now fails right in the middle
> > > of installation and needs the modprobe -r, modprobe stunt to network
> > > again.
> >=20
> > Matt, Michael,
> >=20
> > The tg3 driver has regressed for the 5714S since Linux 2.6.32.  Marc
> > Haber found this in the backported version included in our stable
> > update, but also confirmed it in Linux 3.0.
> >=20
> > Bringing the interface down and then up again (which the installer does
> > for some reason) can leave it unable to pass traffic (possibly after
> > working for a few packets) until the module is reloaded.
> >=20
> > I asked Marc to check whether reverting the power management changes
> > (071697e2bcd8dff2af4d6fdd6525c2324f89553b,
> > d237d9ecf06a00f0ebca657958cf2a1e92940796) made a difference, but it
> > doesn't seem to.
> >=20
> > There is more information in the bug log at
> > <http://bugs.debian.org/645308>.
>=20
> Where can I get the sources for this driver?  Commit
> 9e975cc291d80d5e4562d6bed15ec171e896d69b, entitled
> "tg3: Fix io failures after chip reset" has been a common source of
> problems.

Our current package has Linux 3.0.6 which includes the backport of that
change.  However, it is *not* included in my backport to 2.6.32 so it
doesn't explain the original report.

The backported version can be found in:

git://anonscm.debian.org/kernel/linux-2.6.git squeeze

Ben.

--=20
Ben Hutchings
DNRC Motto:  I can please only one person per day.
Today is not your day.  Tomorrow isn't looking good either.

--=-YNmjl9Zl/yEwb6KNMGiB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATqX5K+e/yOyVhhEJAQqFbQ//V9S7YNBumb40Kx5eJQPciIn7MkKXpEnx
pnjRuYFzwq0KxWiC2z1oI4Yd20Wt8/2GbLUuAT6aeF/XXIxaBgMiVaZxsEYMsAV9
yRa3Eh07mr3Wp5o5WskbChaPJL29mofdTDRLIZgG6jVYEy0OAQgeSG5R+T1aHNo2
WMwojq46ZtmIc1GIaH0nE6UIZkDWOH0Vlgicm7W8y/6j/UImAM9Xa97qzhXIK9HG
j3nEPidOImu4H0+ESiLmNV2b4HlZux2zVL0RT5hG4p63sBbctY/KTD1D258cMNEZ
rwv7BZl0Mna2fa8YrfXyJO5NjBAfQdWOEHQTldibYkawgX9o2w1EwYCTZPf1QZ7X
wQrGsb0mTY/BQD1BHP7O8r0RaM7kyIdNb8A6VwQ9m5l+DhjLEJifuEr1xBmKdHWJ
lomIFCO7eI6l8XlLAcvCATudyCYYn37sF/diJvPbYITVsAG5AeTmUbP0ZfqhT66/
WQJC0/ZE3tUpAfafhu0RAMhMrX/hLzixajhC7uZRUb4ZEXamjwvD8k5b/yD7bS5H
Lr7OnzrgyqADC01jh4lyXFTQY/ZsmZlhVQpx3tDrDObOXGjvTouetPb44VdbX8OI
1qlKjqkeLITU6nUZFwTI8z6zLzuI4wCWY5H891HfvU8V6IWsZrQ+3/VB9s1qAnw6
iKJqKLc+9r0=
=mDaX
-----END PGP SIGNATURE-----

--=-YNmjl9Zl/yEwb6KNMGiB--
