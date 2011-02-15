From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH 02/14] net/fec: release mem_region requested in probe
 in error path and remove
Date: Tue, 15 Feb 2011 21:00:20 +0100
Message-ID: <20110215200020.GS13279@pengutronix.de>
References: <20110214082525.GD13279@pengutronix.de>
 <20110214.110549.193710827.davem@davemloft.net>
 <20110215085305.GL13279@pengutronix.de>
 <20110215.103159.193730541.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, shawn.guo@freescale.com,
	kernel@pengutronix.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:54316 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752783Ab1BOUA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Feb 2011 15:00:27 -0500
Content-Disposition: inline
In-Reply-To: <20110215.103159.193730541.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 15, 2011 at 10:31:59AM -0800, David Miller wrote:
> From: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
> Date: Tue, 15 Feb 2011 09:53:05 +0100
>=20
> > On Mon, Feb 14, 2011 at 11:05:49AM -0800, David Miller wrote:
> >> These merge commits look ugly and Linus wants them minimized.
> > Hmm, right, I don't get why this looks uglier for Linus than a merg=
e of
> > a tree that bases on something you already have.  I guess you're to=
o
> > annoyed by now to explain why you think it does.
>=20
> What's so hard to understand about the fact that when I pull from
> someone I do not want any commits unrelated to the work that person
> is sending me?
Perfectly fine, I can live with this explanation.  Next time say that a=
t
once :-)
=20
> >> Either you follow the rules and my expectations, which is that whe=
n you
> >> give me a GIT tree to pull from it's based upon one of my trees, o=
r
> >> I don't pull from you.
> > So I rebased my tree on something older.  It now starts at
> >=20
> > 	c69b909 (pch_can: fix module reload issue with MSI)
> >=20
> > which is already in net-next/master.
>=20
> You need to send a new pull request so that it gets properly tracked
> in patchwork.
Oh, I didn't know that patchwork tracks pull requests, too:

The following changes since commit c69b90920a36b88ab0d649963d81355d865e=
eb05:

  pch_can: fix module reload issue with MSI (2011-02-08 16:37:20 -0800)

are available in the git repository at:
  git://git.pengutronix.de/git/ukl/linux-2.6.git fec

Uwe Kleine-K=F6nig (14):
      net/fec: no need to cast arguments for memcpy
      net/fec: release mem_region requested in probe in error path and =
remove
      net/fec: don't free an irq that failed to be requested
      net/fec: no need to check for validity of ndev in suspend and res=
ume
      net/fec: no need to memzero private data
      net/fec: put the ioremap cookie immediately into a void __iomem p=
ointer
      net/fec: consolidate all i.MX options to CONFIG_ARM
      net/fec: add phy_stop to fec_enet_close
      net/fec: consistenly name struct net_device pointers "ndev"
      net/fec: some whitespace cleanup
      net/fec: reorder functions a bit allows removing forward declarat=
ions
      net/fec: provide device for dma functions and matching sizes for =
map and unmap
      net/fec: postpone unsetting driver data until the hardware is sto=
pped
      net/fec: enable flow control and length check on enet-mac

 drivers/net/Kconfig |    3 +-
 drivers/net/fec.c   |  650 ++++++++++++++++++++++++++-----------------=
--------
 2 files changed, 328 insertions(+), 325 deletions(-)

Thanks
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
