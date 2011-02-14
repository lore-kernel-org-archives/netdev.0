From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/14] net/fec: release mem_region requested in probe
 in error path and remove
Date: Mon, 14 Feb 2011 11:05:49 -0800 (PST)
Message-ID: <20110214.110549.193710827.davem@davemloft.net>
References: <20110213210709.GA13279@pengutronix.de>
	<20110213.131531.57465973.davem@davemloft.net>
	<20110214082525.GD13279@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, shawn.guo@freescale.com,
	kernel@pengutronix.de
To: u.kleine-koenig@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34030
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751226Ab1BNTFN convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Feb 2011 14:05:13 -0500
In-Reply-To: <20110214082525.GD13279@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
Date: Mon, 14 Feb 2011 09:25:25 +0100

> Hi David,
>=20
> On Sun, Feb 13, 2011 at 01:15:31PM -0800, David Miller wrote:
>> From: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
>> Date: Sun, 13 Feb 2011 22:07:09 +0100
>> > On Fri, Feb 11, 2011 at 09:25:32PM -0800, David Miller wrote:
>> >> I can't pull from that tree because it is _NOT_ based upon net-ne=
xt-2.6
>> >> and therefore brings in all kinds of commits not related to your =
work.
>> > Sorry, I'm not used to the customs on netdev.  I can rebase, but s=
till I
>> > wonder about the reason you cannot pull for.  The only reason I ca=
n
>> > imagine is that you fear unrelated breakage when taking these patc=
hes
>> > that are already in Linus' tree.  But if it's that, wouldn't it be=
 great
>> > the realize this breakage already now and not only during the next=
 merge
>> > window?
>>=20
>> My trees only merge in Linus's tree when absolutely necessary,
>> to resolve conflicts or similar.
> You don't merge Linus' tree, you merge mine that just happen to be ba=
sed
> on a newer version of Linus' tree. I'm sure Linus won't yell on you f=
or
> that. He only objects to merge directly from his tree, because the
> result for him is an "empty" merge.

You don't get it.

These merge commits look ugly and Linus wants them minimized.

Either you follow the rules and my expectations, which is that when you
give me a GIT tree to pull from it's based upon one of my trees, or
I don't pull from you.

