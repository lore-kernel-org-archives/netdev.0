From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2] ipsec: be careful of non existing mac headers
Date: Thu, 23 Feb 2012 16:53:58 -0500 (EST)
Message-ID: <20120223.165358.2006843858723707510.davem@davemloft.net>
References: <1330028243.15610.40.camel@edumazet-laptop>
	<20120223.152314.1111200746248162115.davem@davemloft.net>
	<1330030502.15610.44.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: darkbasic@linuxsystems.it, netdev@vger.kernel.org,
	openadsl-users@lists.sourceforge.net,
	openadsl-devel@lists.sourceforge.net, 660804@bugs.debian.org,
	support@traverse.com.au, support@rocksolidelectronics.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56761 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753170Ab2BWVyf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 16:54:35 -0500
In-Reply-To: <1330030502.15610.44.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 23 Feb 2012 21:55:02 +0100

> Niccolo Belli reported ipsec crashes in case we handle a frame withou=
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

Applied and queued up for -stable, thanks.

BTW, if anyone wants to see what's queued up for -stable I have a publi=
c
patchwork bundle for it:

	http://patchwork.ozlabs.org/bundle/davem/stable/

Just FYI.
