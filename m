From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] am79c961a: fix spin_lock usage
Date: Thu, 22 Jan 2009 14:56:15 -0800 (PST)
Message-ID: <20090122.145615.235726630.davem@davemloft.net>
References: <1232663382-10503-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: 12o3l@tiscali.nl, rmk+kernel@arm.linux.org.uk, srostedt@redhat.com,
	netdev@vger.kernel.org
To: u.kleine-koenig@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60170
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758776AbZAVW4N convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2009 17:56:13 -0500
In-Reply-To: <1232663382-10503-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
Date: Thu, 22 Jan 2009 23:29:42 +0100

> spin_lock functions take a pointer to the lock, not the lock itself.
> This error was noticed by compiling ebsa110_defconfig for linux-rt wh=
ere
> the locking functions obviously are more picky about their arguments.
>=20
> Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>

Russell, this fix is real.  Want me to take it or will you?

BTW, I took linux-arm-kernel out of the CC because all of my postings
there bounce simply because I lack reverse DNS :-/
