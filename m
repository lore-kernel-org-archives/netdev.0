From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: [PATCH] SSB / B44: fix WOL for BCM4401
Date: Wed, 3 Dec 2014 17:23:15 +0100
Message-ID: <20141203172315.120040c2@wiggum>
References: <20141201111125.GA11974@localhost.localdomain>
	<1417466798-15735-1-git-send-email-Andrej.Skvortzov@gmail.com>
	<20141201221023.79ffb40d@wiggum>
	<20141202200129.GA4580@crion89>
	<20141202211211.7e08b935@wiggum>
	<547E3BF5.5060201@lwfinger.net>
	<20141203161855.50951aa8@wiggum>
	<20141203161452.GD2896@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/W55AsAgnlqTaZg/M34CqBBN"; protocol="application/pgp-signature"
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	Andrey Skvortsov <andrej.skvortzov@gmail.com>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>, Gary.Zambrano@qlogic.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	b43-dev <b43-dev@lists.infradead.org>,
	=?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141203161452.GD2896@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/W55AsAgnlqTaZg/M34CqBBN
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Wed, 3 Dec 2014 11:14:52 -0500
"John W. Linville" <linville@tuxdriver.com> wrote:

> On Wed, Dec 03, 2014 at 04:18:55PM +0100, Michael B=C3=BCsch wrote:
> > On Tue, 02 Dec 2014 16:23:49 -0600
> > Larry Finger <Larry.Finger@lwfinger.net> wrote:
> >=20
> > > On 12/02/2014 02:12 PM, Michael B=C3=BCsch wrote:
> > > > On Tue, 2 Dec 2014 23:01:29 +0300
> > > > Andrey Skvortsov <andrej.skvortzov@gmail.com> wrote:
> > > >
> > > >> On Mon, Dec 01, 2014 at 10:10:23PM +0100, Michael B=C3=BCsch wrote:
> > > >>> On Mon,  1 Dec 2014 23:46:38 +0300
> > > >>> Andrey Skvortsov <andrej.skvortzov@gmail.com> wrote:
> > > >>>
> > > >>>> Wake On Lan was not working on laptop DELL Vostro 1500.
> > > >>>> If WOL was turned on, BCM4401 was powered up in suspend mode. LE=
Ds blinked.
> > > >>>> But the laptop could not be woken up with the Magic Packet. The =
reason for
> > > >>>> that was that PCIE was not enabled as a system wakeup source and
> > > >>>> therefore the host PCI bridge was not powered up in suspend mode.
> > > >>>> PCIE was not enabled in suspend by PM because no child devices w=
ere
> > > >>>> registered as wakeup source during suspend process.
> > > >>>> On laptop BCM4401 is connected through the SSB bus, that is conn=
ected to the
> > > >>>> PCI-Express bus. SSB and B44 did not use standard PM wakeup func=
tions
> > > >>>> and did not forward wakeup settings to their parents.
> > > >>>> To fix that B44 driver enables PM wakeup and registers new wakeu=
p source
> > > >>>> using device_set_wakeup_enable(). Wakeup is automatically report=
ed to the parent SSB
> > > >>>> bus via power.wakeup_path. SSB bus enables wakeup for the parent=
 PCI bridge, if there is any
> > > >>>> child devices with enabled wakeup functionality. All other steps=
 are
> > > >>>> done by PM core code.
> > > >>>
> > > >>> Thanks, this looks good.
> > > >>> I assume you tested this (I currently don't have a device to test=
 this).
> > > >>
> > > >> Sure, I've tested it. WOL from suspend is working and after resume=
 from hibernate Ethernet is working too.
> > > >
> > > > That sounds good, indeed.
> > > > I'd still prefer, if someone with b43 (wireless) would test it, too.
> > >=20
> > > I did a partial test with my PowerBook G4. With the patch installed, =
it would=20
> > > both suspend and hibernate, but WOL would be impossible. This compute=
r uses a=20
> > > PCMCIA version of the BCM4318, and power is turned off to the PCMCIA =
card when=20
> > > suspended or hibernating.
> >=20
> > Thanks for testing.
> >=20
> > John, can you take this one? Or do we need to split the b44 part out?
> > I added my Signed-off.
>=20
> Um, sure...3.19 is OK I presume?

I think we could even wait for 3.20.

--=20
Michael

--Sig_/W55AsAgnlqTaZg/M34CqBBN
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJUfzj1AAoJEPUyvh2QjYsOTmoQAMevc185S57uGkwv0paXBp0T
V9QgJQDXzvoGJur9dnYUGCwfXnkWs2T+2qwP2rvjtMpusBn2u/r6gUKH7wqn3bJr
bnf/fCVc7zOdfNN7K3lLYKjRZ6PZ07OsWqQAy5HvjAFH940eKBEnyhTtKnWnc19F
xjPdSmHszvUpmjsiDWj+aIKU0VqUZmKJnTSJKx7FAb/EF2twp44GQWKrk9xIUFZ8
nUgeye4+ew28S1e/6icvmPHDRTZiGHLkoAwLtbNrEm8wwxhW3qpz68NWZ9zJiRP9
sdjOhcqqm0SauEB2Kd5rGv/Iwmg+1vTmAlGT7cQSpwdV0+zQY6OIngVs8PZShu4F
sYDmiZ2JQKir92QvbvvzKbX7WcotLIxwo+x8TNMPaOTzYV8PCdewN9drD+d3kWDJ
SShBAHPMytYTxihfj4K+MQJ78PDj1LS2o8yPQY9lvfi4rLWYDLEuC0GXLFqMYLut
SqdHpHM1+kJ9BXOCeUgYFrPpEV0DqfMu6lj/aGrQj0fzVrAtIZhRRxgMl9jU+Uhl
brZAwfpwt10huU4faSZN/RK/H+Hauv4i1H+7I23Wm3PA442RiFRNgxp35/bXp7Ws
qcDNnBzWrNtjoxLiIe0CX8Rna0xef6UcsXlYaVzeFQJWCHEpq6T78/IUy6VJM68p
mhgRzlEArQn7jxLURSEi
=BAFn
-----END PGP SIGNATURE-----

--Sig_/W55AsAgnlqTaZg/M34CqBBN--
