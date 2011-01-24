From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 03/16] net: reduce and unify printk level in
 netdev_fix_features()
Date: Mon, 24 Jan 2011 15:45:56 -0800 (PST)
Message-ID: <20110124.154556.229738721.davem@davemloft.net>
References: <cover.1295734270.git.mirq-linux@rere.qmqm.pl>
	<29e476c368b6580f7ff5215ca759b69c75d0e021.1295734271.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60115
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752766Ab1AXXpV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jan 2011 18:45:21 -0500
In-Reply-To: <29e476c368b6580f7ff5215ca759b69c75d0e021.1295734271.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Sat, 22 Jan 2011 23:14:12 +0100 (CET)

> Reduce printk() levels to KERN_INFO in netdev_fix_features() as this =
will
> be used by ethtool and might spam dmesg unnecessarily.
>=20
> This converts the function to use netdev_info() instead of plain prin=
tk().
>=20
> As a side effect, bonding and bridge devices will now log dropped fea=
tures
> on every slave device change.
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

I've applied this with the 80-column issues fixed up, we can discuss
using KERN_DEBUG or whatever in follow-up patches.

Thanks.
