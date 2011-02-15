From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH 02/14] net/fec: release mem_region requested in probe
 in error path and remove
Date: Tue, 15 Feb 2011 09:53:05 +0100
Message-ID: <20110215085305.GL13279@pengutronix.de>
References: <20110213210709.GA13279@pengutronix.de>
 <20110213.131531.57465973.davem@davemloft.net>
 <20110214082525.GD13279@pengutronix.de>
 <20110214.110549.193710827.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, shawn.guo@freescale.com,
	kernel@pengutronix.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:37787 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751178Ab1BOIxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Feb 2011 03:53:09 -0500
Content-Disposition: inline
In-Reply-To: <20110214.110549.193710827.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Mon, Feb 14, 2011 at 11:05:49AM -0800, David Miller wrote:
> From: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
> Date: Mon, 14 Feb 2011 09:25:25 +0100
> > On Sun, Feb 13, 2011 at 01:15:31PM -0800, David Miller wrote:
> >> From: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
> >> Date: Sun, 13 Feb 2011 22:07:09 +0100
> >> > On Fri, Feb 11, 2011 at 09:25:32PM -0800, David Miller wrote:
> >> >> I can't pull from that tree because it is _NOT_ based upon net-=
next-2.6
> >> >> and therefore brings in all kinds of commits not related to you=
r work.
> >> > Sorry, I'm not used to the customs on netdev.  I can rebase, but=
 still I
> >> > wonder about the reason you cannot pull for.  The only reason I =
can
> >> > imagine is that you fear unrelated breakage when taking these pa=
tches
> >> > that are already in Linus' tree.  But if it's that, wouldn't it =
be great
> >> > the realize this breakage already now and not only during the ne=
xt merge
> >> > window?
> >>=20
> >> My trees only merge in Linus's tree when absolutely necessary,
> >> to resolve conflicts or similar.
> > You don't merge Linus' tree, you merge mine that just happen to be =
based
> > on a newer version of Linus' tree. I'm sure Linus won't yell on you=
 for
> > that. He only objects to merge directly from his tree, because the
> > result for him is an "empty" merge.
>=20
> You don't get it.
>=20
> These merge commits look ugly and Linus wants them minimized.
Hmm, right, I don't get why this looks uglier for Linus than a merge of
a tree that bases on something you already have.  I guess you're too
annoyed by now to explain why you think it does.
=20
> Either you follow the rules and my expectations, which is that when y=
ou
> give me a GIT tree to pull from it's based upon one of my trees, or
> I don't pull from you.
So I rebased my tree on something older.  It now starts at

	c69b909 (pch_can: fix module reload issue with MSI)

which is already in net-next/master.

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
