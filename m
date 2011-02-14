From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH 02/14] net/fec: release mem_region requested in probe
 in error path and remove
Date: Mon, 14 Feb 2011 09:25:25 +0100
Message-ID: <20110214082525.GD13279@pengutronix.de>
References: <20110211110339.GH27982@pengutronix.de>
 <20110211.212532.229740768.davem@davemloft.net>
 <20110213210709.GA13279@pengutronix.de>
 <20110213.131531.57465973.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, shawn.guo@freescale.com,
	kernel@pengutronix.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:35408 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751369Ab1BNIZ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Feb 2011 03:25:28 -0500
Content-Disposition: inline
In-Reply-To: <20110213.131531.57465973.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Sun, Feb 13, 2011 at 01:15:31PM -0800, David Miller wrote:
> From: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
> Date: Sun, 13 Feb 2011 22:07:09 +0100
> > On Fri, Feb 11, 2011 at 09:25:32PM -0800, David Miller wrote:
> >> I can't pull from that tree because it is _NOT_ based upon net-nex=
t-2.6
> >> and therefore brings in all kinds of commits not related to your w=
ork.
> > Sorry, I'm not used to the customs on netdev.  I can rebase, but st=
ill I
> > wonder about the reason you cannot pull for.  The only reason I can
> > imagine is that you fear unrelated breakage when taking these patch=
es
> > that are already in Linus' tree.  But if it's that, wouldn't it be =
great
> > the realize this breakage already now and not only during the next =
merge
> > window?
>=20
> My trees only merge in Linus's tree when absolutely necessary,
> to resolve conflicts or similar.
You don't merge Linus' tree, you merge mine that just happen to be base=
d
on a newer version of Linus' tree. I'm sure Linus won't yell on you for
that. He only objects to merge directly from his tree, because the
result for him is an "empty" merge.
=20
> We don't bring in unrelated changes into my tree, just for the
> sake of doing so.
>=20
> Otherwise Linus gets all of these ugly merge commits when he
> pulls from me, which are entirely unnecessary.
The result Linus gets if you pull my tree based on
v2.6.38-rc4-106-gd247852 (as it is now) is the same as if it were based
on v2.6.38-rc2-210-gc69b909 (which is the most recent commit net-next
currently bases on): my 14 patches and your merge commit. The reason fo=
r
that is that Linus already has the commits between
v2.6.38-rc2-210-gc69b909 and v2.6.38-rc4-106-gd247852. So this is reall=
y
only about when these commits enter *your* tree.

There are currently the following commits in Linus' tree that are used
by commits in net-next as parents:

	c56eb8fb6dccb83d9fe62fd4dc00c834de9bc470
	ff76015f3bdfbc482c723cb4f2559cef84d178ca (*)
	c753796769e4fb0cd813b6e5801b3c01f4681d4f
	0c21e3aaf6ae85bee804a325aa29c325209180fd (*)
	e92427b289d252cfbd4cb5282d92f4ce1a5bb1fb (*)
	1bae4ce27c9c90344f23c65ea6966c50ffeae2f5
	7cc2edb83447775a34ed3bf9d29d8295a434b523 (*)
	8f2771f2b85aea4d0f9a0137ad3b63d1173c0962 (*)
	c4c93106741bbf61ecd05a2a835af8e3bf31c1bd (*)
	c7c1806098752c1f46943d8db2c69aff07f5d4bc (*)
	479600777bb588724d044815415f7d708d06644b (*)
	1e6d93e45b231b3ae87c01902ede2315aacfe976 (*)
	9b00b4157f7b3265de291ac8979a5f1611ce64ab
	c69b90920a36b88ab0d649963d81355d865eeb05 (*)

and you don't want to take d247852 to this list because it's newer than
all these? How did you decide to take the newest in the list above and
why was that OK?
And as a last point let me note, that from Linus' POV the commits marke=
d
with an asterisk above go into net-next by an empty merge.=20
=09
Can you please reping me if you still consider that I should rebase my
tree for you to be able to merge it?

Best regards and thanks
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
