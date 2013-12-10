From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bgmac: start/stop PHY on netdev open/stop
Date: Tue, 10 Dec 2013 18:10:02 -0500 (EST)
Message-ID: <20131210.181002.2084260138032882245.davem@davemloft.net>
References: <1386692379-16648-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, hauke@hauke-m.de
To: zajec5@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52942 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751243Ab3LJXKD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 18:10:03 -0500
In-Reply-To: <1386692379-16648-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Rafa=A9=A9 Mi=A9=A9ecki <zajec5@gmail.com>
Date: Tue, 10 Dec 2013 17:19:39 +0100

> I've realized that I need to call ethtool command to get Ethernet
> working after booting. Ex call: ethtool -s eth0 autoneg on
> It was fixing Ethernet even if auto-negotiation was already on.
>=20
> Adding calls to phy_start and phy_stop look like a real solution.
>=20
> Signed-off-by: Rafa=A9=A9 Mi=A9=A9ecki <zajec5@gmail.com>

Applied.

Please in the future make it clear what tree a patch is meant for,
I assumed this is only for net-next so that's where I applied it.

Thanks.
