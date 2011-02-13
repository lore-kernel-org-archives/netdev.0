From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/14] net/fec: release mem_region requested in probe
 in error path and remove
Date: Sun, 13 Feb 2011 13:15:31 -0800 (PST)
Message-ID: <20110213.131531.57465973.davem@davemloft.net>
References: <20110211110339.GH27982@pengutronix.de>
	<20110211.212532.229740768.davem@davemloft.net>
	<20110213210709.GA13279@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, shawn.guo@freescale.com,
	kernel@pengutronix.de
To: u.kleine-koenig@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47669
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754744Ab1BMVOz convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Feb 2011 16:14:55 -0500
In-Reply-To: <20110213210709.GA13279@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
Date: Sun, 13 Feb 2011 22:07:09 +0100

> Hi David,
>=20
> On Fri, Feb 11, 2011 at 09:25:32PM -0800, David Miller wrote:
>> I can't pull from that tree because it is _NOT_ based upon net-next-=
2.6
>> and therefore brings in all kinds of commits not related to your wor=
k.
> Sorry, I'm not used to the customs on netdev.  I can rebase, but stil=
l I
> wonder about the reason you cannot pull for.  The only reason I can
> imagine is that you fear unrelated breakage when taking these patches
> that are already in Linus' tree.  But if it's that, wouldn't it be gr=
eat
> the realize this breakage already now and not only during the next me=
rge
> window?

My trees only merge in Linus's tree when absolutely necessary,
to resolve conflicts or similar.

We don't bring in unrelated changes into my tree, just for the
sake of doing so.

Otherwise Linus gets all of these ugly merge commits when he
pulls from me, which are entirely unnecessary.


