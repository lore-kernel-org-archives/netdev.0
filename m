From: David Miller <davem@davemloft.net>
Subject: Re: pull request [net]: batman-adv 20150106
Date: Tue, 06 Jan 2015 14:25:14 -0500 (EST)
Message-ID: <20150106.142514.108109720918651317.davem@davemloft.net>
References: <1420542605-28865-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: antonio@meshcoding.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53243 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751284AbbAFTZR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 14:25:17 -0500
In-Reply-To: <1420542605-28865-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Antonio Quartulli <antonio@meshcoding.com>
Date: Tue,  6 Jan 2015 12:09:59 +0100

> here you have some small fixes for your 'net' tree.
>=20
> Patch 1 fixes a regression in the "bonding" code introduced while
> implementing the multi-interface optimization feature, by Simon
> Wunderlich.
>=20
> Patch 2 ensures that the "last-seen" timestamp for a newly created
> originator object is properly initialised in order to avoid a non-cri=
tical
> race condition, by Linus L=FCssing.
>=20
> Patch 3 avoids false positive splats when lockdep is enabled by assig=
ning
> the proper lock class to locks used by the network coding feature, by
> Martin Hundeb=F8ll.
>=20
> Patches 4 and 5 fix the code counting the amount of multicast-disable=
d
> nodes in the network (used to avoid to enable the multicast optimisat=
ion
> when not possible), by Linus L=FCssing.
>=20
> Patch 6 fixes a memory leak in the Translation Table code that can be
> triggered by doubling the current originator interval, by Linus L=FCs=
sing.

Pulled, thanks Antonio.
