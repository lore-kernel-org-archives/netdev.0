From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] via-velocity: unconditionally drop frames with bad l2
 length
Date: Tue, 17 Nov 2015 14:37:29 -0500 (EST)
Message-ID: <20151117.143729.404916007454778979.davem@davemloft.net>
References: <20151113232133.GA21633@electric-eye.fr.zoreil.com>
	<1447677392-17400-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57993 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754625AbbKQThb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 14:37:31 -0500
In-Reply-To: <1447677392-17400-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Mon, 16 Nov 2015 14:36:32 +0200

> By default the driver allowed incorrect frames to be received. What i=
s
> worse the code does not handle very short frames correctly. The FCS
> length is unconditionally subtracted, and the underflow can cause
> skb_put to be called with large number after implicit cast to unsigne=
d.
> And indeed, an skb_over_panic() was observed with via-velocity.
>=20
> This removes the module parameter as it does not work in it's
> current state, and should be implemented via NETIF_F_RXALL if needed.
>=20
> Suggested-by: Francois Romieu <romieu@fr.zoreil.com>
> Signed-off-by: Timo Ter=E4s <timo.teras@iki.fi>

Applied, thanks Timo.
