From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net,v2] ip_gre: fix msg_name parsing for
 recvfrom/recvmsg
Date: Wed, 18 Dec 2013 17:45:33 -0500 (EST)
Message-ID: <20131218.174533.1105966791782254998.davem@davemloft.net>
References: <20131214.005232.1773340007123224291.davem@davemloft.net>
	<1387184529-6911-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, pshelar@nicira.com
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57422 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752442Ab3LRWpf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 17:45:35 -0500
In-Reply-To: <1387184529-6911-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Mon, 16 Dec 2013 11:02:09 +0200

> ipgre_header_parse() needs to parse the tunnel's ip header and it
> uses mac_header to locate the iphdr. This got broken when gre tunneli=
ng
> was refactored as mac_header is no longer updated to point to iphdr.
> Introduce skb_pop_mac_header() helper to do the mac_header assignment
> and use it in ipgre_rcv() to fix msg_name parsing.
>=20
> Bug introduced in commit c54419321455 (GRE: Refactor GRE tunneling co=
de.)
>=20
> Cc: Pravin B Shelar <pshelar@nicira.com>
> Signed-off-by: Timo Ter=E4s <timo.teras@iki.fi>
> ---
> Updated as suggested. Please queue for -stable too.

Applied and queued up for -stable, thanks!
