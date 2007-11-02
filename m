From: Adrian Bunk <bunk@kernel.org>
Subject: Re: build #337 failed for 2.6.24-rc1-gb1d08ac In function
	`usbnet_set_settings':
Date: Fri, 2 Nov 2007 20:55:17 +0100
Message-ID: <20071102195517.GW30287@stusta.de>
References: <200711012024.57412.toralf.foerster@gmx.de> <200711021145.15542.david-b@pacbell.net> <20071102185751.GV30287@stusta.de> <200711021230.22588.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	Toralf =?utf-8?Q?F=C3=B6rster?= <toralf.foerster@gmx.de>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:53173 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754307AbXKBTzl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2007 15:55:41 -0400
Content-Disposition: inline
In-Reply-To: <200711021230.22588.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 02, 2007 at 12:30:22PM -0700, David Brownell wrote:
> On Friday 02 November 2007, Adrian Bunk wrote:
> > This approach has two disadvantages:
> > - it's complicated
>=20
> No more so than the problem itself.
>=20
>=20
> > - the MII stuff is an implementation detail, and we shouldn't bothe=
r
> > =C2=A0 the user with it (especially since we can do better)
>=20
> That's a Kconfig policy that's not always followed.

Sure it's not yet always followed.

But kernel developers have to become more aware that the vast majority=20
of kconfig users are not kernel hackers and act accordingly.

I'm not talking about the infamous Aunt Tillie, but being able to=20
build your own kernel is even required for LPIC-1. [1]

> In this
> case, I was getting fed up with "select".  It so rarely does
> what it needs to do, and I've started to think it'd be better
> to just always avoid that fragility than battle it.

Regarding this bug, "select" is completely innocent...

> > If you want to keep the #ifdef's, what's the problem with the secon=
d=20
> > patch I proposed to fix this bug?
>=20
> For one thing, I didn't see it until after I posted this one...
> other than that, the basic approach could well be fine; I didn't
> go through it in detail.
>=20
> But on the other hand, it seems that only the ASIX code will work
> right; the DM9601 and MCS7830 Kconfig is different/wrong.

I'm not seeing the problem.

Which configuration will be handled wrongly?

> - Dave

cu
Adrian

[1] http://www.lpi.org/en/lpi/english/certification/the_lpic_program/ex=
am_102_detailed_objectives

--=20

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

