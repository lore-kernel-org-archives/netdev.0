From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: [PATCH] am79c961a: fix spin_lock usage
Date: Thu, 22 Jan 2009 23:40:36 +0000
Message-ID: <20090122234036.GA23484@flint.arm.linux.org.uk>
References: <1232663382-10503-1-git-send-email-u.kleine-koenig@pengutronix.de> <20090122.145615.235726630.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: u.kleine-koenig@pengutronix.de, srostedt@redhat.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:46358 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755468AbZAVXlR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 18:41:17 -0500
Content-Disposition: inline
In-Reply-To: <20090122.145615.235726630.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 22, 2009 at 02:56:15PM -0800, David Miller wrote:
> From: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
> Date: Thu, 22 Jan 2009 23:29:42 +0100
>=20
> > spin_lock functions take a pointer to the lock, not the lock itself=
=2E
> > This error was noticed by compiling ebsa110_defconfig for linux-rt =
where
> > the locking functions obviously are more picky about their argument=
s.
> >=20
> > Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
>=20
> Russell, this fix is real.  Want me to take it or will you?

I'll take it.

> BTW, I took linux-arm-kernel out of the CC because all of my postings
> there bounce simply because I lack reverse DNS :-/

No need; in theory I've whitelisted your IP.  However, I've dropped
12o3l@tiscali.nl from the CC because that address bounces.

--=20
Russell King
