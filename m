From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: Re: [PATCH] net: ethernet: remove unneeded dependency of mvneta and
 update help text
Date: Tue, 18 Feb 2014 12:45:12 -0300
Message-ID: <20140218154512.GA10691@localhost>
References: <1392719391-8851-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <20140218122952.GM7862@titan.lakedaemon.net>
 <20140218134532.7607a616@skate>
 <20140218125206.GN7862@titan.lakedaemon.net>
 <20140218141303.77c77272@skate>
 <20140218135809.GD17984@lunn.ch>
 <20140218151027.710ab2f3@skate>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Lunn <andrew@lunn.ch>, Jason Cooper <jason@lakedaemon.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	linux-arm-kernel@lists.infradead.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:46354 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755478AbaBRPpU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 10:45:20 -0500
Content-Disposition: inline
In-Reply-To: <20140218151027.710ab2f3@skate>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 18, 2014 at 03:10:27PM +0100, Thomas Petazzoni wrote:
[..]
>=20
> At the very end of the clean up, when even Orion5x support will be
> merged in mach-mvebu/, then we can certainly replace these dependenci=
es
> by a "depends on ARCH_MVEBU". But for the time being, PLAT_ORION seem=
s
> like the right common denominator for all these platforms.
>=20

Last time we talked about this with Sebastian and Andrew it was decided
that the right choice is:

  MACH_KIRKWOOD || MACH_DOVE || MACH_ARMADA_370_XP

Which would become MACH_MVEBU.

Of course, this is near the nitpick boundary, so AFAIC you can leave
PLAT_ORION as in v2, if you feel like.
--=20
Ezequiel Garc=C3=ADa, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com
