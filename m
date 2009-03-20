From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: 2.6.29-rc8: Reported regressions from 2.6.28
Date: Fri, 20 Mar 2009 11:13:53 +0100
Message-ID: <1237544033.5100.143.camel@johannes.local>
References: <MiincthRUSI.A.eKC.F4BvJB@chimera>
	 <1237143683.24621.7.camel@johannes.local> <20090315202603.GA9077@elte.hu>
	 <b6a2187b0903160624gb9d207dv301506e589d93ed4@mail.gmail.com>
	 <1237317742.31814.28.camel@johannes.local>
	 <b6a2187b0903181958ke11abe7tdcbc4efeb950954d@mail.gmail.com>
	 <b6a2187b0903182149x77e416ecuf73be2970173c601@mail.gmail.com>
	 <1237455534.5100.56.camel@johannes.local>
	 <b6a2187b0903192155q33510b57l9d5927538a0f4f99@mail.gmail.com>
	 <1237537967.5100.135.camel@johannes.local>
	 <b6a2187b0903200304l469e3eeet87c51b1cddb43ea8@mail.gmail.com>
	 (sfid-20090320_110431_738151_8D365596)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-yQMXHixSw2lKEUTiMnYT"
Cc: Ingo Molnar <mingo@elte.hu>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Adrian Bunk <bunk@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>
To: Jeff Chua <jeff.chua.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:60210 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761220AbZCTKPJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 06:15:09 -0400
In-Reply-To: <b6a2187b0903200304l469e3eeet87c51b1cddb43ea8@mail.gmail.com> (sfid-20090320_110431_738151_8D365596)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-yQMXHixSw2lKEUTiMnYT
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2009-03-20 at 18:04 +0800, Jeff Chua wrote:
> On Fri, Mar 20, 2009 at 4:32 PM, Johannes Berg
> <johannes@sipsolutions.net> wrote:
> > 1) It can't be before iwconfig which will result in "SET failed on
> > device wlan0 ; Device or resource busy".
> >  So your point 1) confuses me. Can you
> > explain that a little more?
>=20
> This is what happened ...
>=20
> # modprobe -r iwlagn
> # modprobe iwlagn
> # ifconfig wlan0 up
> # iwconfig wlan0 mode Managed
> Error for wireless request "Set Mode" (8B06) :
>     SET failed on device wlan0 ; Device or resource busy.

Oh, ok, yes, you cannot change the mode while the interface is up.
Though I guess setting it to the same mode should be accepted. Not that
it matters, the default mode is "managed" anyway.

> > As for 2), that is very very strange since ap auto channel auto is the
> > default, so saying that before you do anything else should do anything
> > at all.
> >
> > I suspect something is going on in the driver because the ifconfig orde=
r
> > matters and for mac80211, it shouldn't make a difference when the state
> > machine is really started. I'll probably need to try to reproduce this,
> > but to be honest between the varying failure modes, undefined wireless
> > extensions semantics, etc. I'm not very confident I can.
>=20
> I'll try all the different combination again for 2.6.28, and see if
> it's the same, and on the other AP that seems harder to associate (but
> works well in 2.6.28, and other OSs include Nokia phones ... so I
> don't think it's the AP problem ... because it's been around a while
> and gone thru many 2.6.xx).

Yeah, I have to admit that an AP problem doesn't make much sense -- but
the entire failure mode doesn't make much sense to me so far.

> It worked so well before that I didn't even bother to think twice, and
> I may have made silly mistakes along the way, so pardon me if I
> confused you.

No worries. It really should still work well. Can I convince you to try
getting the packet dump I asked for in another mail?

johannes

--=-yQMXHixSw2lKEUTiMnYT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJw2xeAAoJEKVg1VMiehFYR0EP/3RyBDj/0qUpV46pBzb0Tdhg
l7fdOFUo93Psc1nF3Jjh57XIWqftVDDNSUwfRcjhqolFTvP/FIxVL32LXcZh2Ilm
WC64BNUwVg9JgdjRd/eqsS7fVNfiSM2zTqaaQTVDLc2P7YjGtnKVwhQdJuL2iRHp
8+0dJ8iqXuhaAvDX9cRfOIB1WUxi/5J1oPJ6RjvJZB88IqQng1YZgfgzvfR2SIPD
7bZRWbqadZE0ij/gaOYCjtb+95QB2O1EaVLJMghDjR8tKGq7KAeuWLXgBY9F67Gx
2njcdbuzJOvKfo0hkBDA8nalWXJu2kqHxpL9HwkTU0UQ1Q1g+Q4PydjHCBRmMFEL
86uCip289z/x/2KFSd8ZeUiPRSqYJ699hrF2wh9m2WOso19W2LL/3lmbxj/ruEbr
1tgTiuWlmLim0aFpnKqKL+E9AhgNzW17GtkNi+AogavdqOs68dTsqZ2WCgPk8CbA
y7w6YC9KL7P0OkSSOmFpsooDAYFlr408ABq+Z/FR9dYAgHVWlAXPbeh0/BjIHR5P
A5VjiRKP7oN29oFICS6j673rmT7S2ZLF4owbU+uqQbUQZkZQoxDag8XiA6R3MnhI
j9q7CC9A8V6atyoUpmyNuytoF6U8XmX1T/tUEqFGGzgC8HGHWNqXGEMT1IQC4zo2
USNE9QQYIqVkUNcObeDf
=sbgw
-----END PGP SIGNATURE-----

--=-yQMXHixSw2lKEUTiMnYT--

