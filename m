From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 42809] New: kernel panic when receiving an ipsec packet
Date: Thu, 23 Feb 2012 15:11:15 -0500 (EST)
Message-ID: <20120223.151115.1646872434333284038.davem@davemloft.net>
References: <1329962785.15610.8.camel@edumazet-laptop>
	<4F46430D.3060802@linuxsystems.it>
	<1330007786.15610.26.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: darkbasic@linuxsystems.it, netdev@vger.kernel.org,
	openadsl-users@lists.sourceforge.net,
	openadsl-devel@lists.sourceforge.net, 660804@bugs.debian.org,
	support@traverse.com.au, support@rocksolidelectronics.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55966 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756557Ab2BWUMS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 15:12:18 -0500
In-Reply-To: <1330007786.15610.26.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 23 Feb 2012 15:36:26 +0100

> [PATCH] ipsec: be careful of non existing mac headers
>=20
> Nicollo Belli reported ipsec crashes in case we handle a frame withou=
t
> mac header (atm in his case)
>=20
> Before copying mac header, better make sure it is present.
>=20
> Bugzilla reference:  https://bugzilla.kernel.org/show_bug.cgi?id=3D42=
809
>=20
> Reported-by: Niccol=F2 Belli <darkbasic@linuxsystems.it>
> Tested-by: Niccol=F2 Belli <darkbasic@linuxsystems.it>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Three instances of the same piece of code, maybe a helper function is
appropriate at that point? :-) You might even get ambitious and add a
big comment to that helper function explaining the situation.
