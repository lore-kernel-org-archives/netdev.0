From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: fec: set mac address unconditionally
Date: Mon, 03 Oct 2016 01:28:03 -0400 (EDT)
Message-ID: <20161003.012803.1597598115167533192.davem@davemloft.net>
References: <1475228770-17504-1-git-send-email-g.schenk@eckelmann.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: fugang.duan@nxp.com, netdev@vger.kernel.org, kernel@pengutronix.de
To: g.schenk@eckelmann.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38364 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750890AbcJCF2G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2016 01:28:06 -0400
In-Reply-To: <1475228770-17504-1-git-send-email-g.schenk@eckelmann.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gavin Schenk <g.schenk@eckelmann.de>
Date: Fri, 30 Sep 2016 11:46:10 +0200

> If the mac address origin is not dt, you can only safely assign a mac
> address after "link up" of the device. If the link is off the clocks are
> disabled and because of issues assigning registers when clocks are off the
> new mac address cannot be written in .ndo_set_mac_address() on some soc's.
> This fix sets the mac address unconditionally in fec_restart(...) and
> ensures consistency between fec registers and the network layer.
> 
> Signed-off-by: Gavin Schenk <g.schenk@eckelmann.de>
> Acked-by: Fugang Duan <fugang.duan@nxp.com>
> Acked-by: Uwe Kleine-König <u.kleine-koenig@pengutronix.de>
> Fixes: 9638d19e4816 ("net: fec: add netif status check before set mac address")
> ---
> Changes since (implicit) v1:
> - reword commit log as suggested by Uwe
> - added Acks

Applied and queued up for -stable, thanks.
