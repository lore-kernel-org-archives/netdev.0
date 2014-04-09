From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: Re: [PATCH 2/2] net: mvneta: fix usage as a module on RGMII
 configurations
Date: Wed, 9 Apr 2014 09:22:41 -0300
Message-ID: <20140409122241.GE1160@arch.cereza>
References: <1395789942-20764-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <1395789942-20764-3-git-send-email-thomas.petazzoni@free-electrons.com>
 <533C1B75.2020803@free-electrons.com>
 <20140403113652.33f11413@skate>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gregory CLEMENT <gregory.clement@free-electrons.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Lior Amsalem <alior@marvell.com>,
	Steve McIntyre <steve@einval.com>,
	linux-arm-kernel@lists.infradead.org, stable@vger.kernel.org,
	Jason Cooper <jason@lakedaemon.net>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:60357 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932592AbaDIMXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2014 08:23:09 -0400
Content-Disposition: inline
In-Reply-To: <20140403113652.33f11413@skate>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Thomas,

On Apr 03, Thomas Petazzoni wrote:
> On Wed, 02 Apr 2014 16:15:17 +0200, Gregory CLEMENT wrote:
>=20
> > > This commit was successfully tested with mvneta compiled as a mod=
ule,
> > > on both the OpenBlocks AX3 (SGMII configuration) and the Armada X=
P GP
> > > (RGMII configuration).
> >=20
> > Unfortunately with this patch, mvneta doesn't work anymore on the
> > Mirabox (Armada 370 based board) on 3.14.I didn't managed to do a
> > simple ping.
> >=20
> > Once I removed this commit then the driver worked again.
>=20
> Problem reproduced. It turns out that some RGMII platforms need the
> PCS_ENABLE bit to be set (e.g: Armada XP GP), while some other
> platforms need the PCS_ENABLE bit to be cleared (e.g: Armada 370
> Mirabox). I've verified that on both platforms.
>=20
> I've asked for more details about this bit to understand in which
> situation it should be set or cleared. I'll get back to you with an
> updated patch once I have enough information to write a fix.
>=20

Just found this commit is in v3.12.17 and prevents booting the A370
Mirabox with nfsroot.

Maybe we should revert it in stable for now until we can solve it?

Unless you have a better idea.
--=20
Ezequiel Garc=EDa, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com
