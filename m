From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] am79c961a: fix spin_lock usage
Date: Thu, 22 Jan 2009 16:16:59 -0800 (PST)
Message-ID: <20090122.161659.261404462.davem@davemloft.net>
References: <1232663382-10503-1-git-send-email-u.kleine-koenig@pengutronix.de>
	<20090122.145615.235726630.davem@davemloft.net>
	<20090122234036.GA23484@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: u.kleine-koenig@pengutronix.de, srostedt@redhat.com,
	netdev@vger.kernel.org
To: rmk@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51791
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755449AbZAWAQ5 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2009 19:16:57 -0500
In-Reply-To: <20090122234036.GA23484@flint.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Russell King <rmk@arm.linux.org.uk>
Date: Thu, 22 Jan 2009 23:40:36 +0000

> On Thu, Jan 22, 2009 at 02:56:15PM -0800, David Miller wrote:
> > From: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
> > Date: Thu, 22 Jan 2009 23:29:42 +0100
> >=20
> > > spin_lock functions take a pointer to the lock, not the lock itse=
lf.
> > > This error was noticed by compiling ebsa110_defconfig for linux-r=
t where
> > > the locking functions obviously are more picky about their argume=
nts.
> > >=20
> > > Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de=
>
> >=20
> > Russell, this fix is real.  Want me to take it or will you?
>=20
> I'll take it.

Great.

> > BTW, I took linux-arm-kernel out of the CC because all of my postin=
gs
> > there bounce simply because I lack reverse DNS :-/
>=20
> No need; in theory I've whitelisted your IP.  However, I've dropped
> 12o3l@tiscali.nl from the CC because that address bounces.

Thanks, I noticed him bounce too.
