From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] bgmac: don't update slot on skb alloc/dma mapping
 error
Date: Tue, 29 Oct 2013 22:59:42 -0400 (EDT)
Message-ID: <20131029.225942.752679895895679051.davem@davemloft.net>
References: <BLU0-SMTP255BD097115C7E52E264D41AC0A0@phx.gbl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, zajec5@gmail.com
To: nlhintz@hotmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52394 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752010Ab3J3C7x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 22:59:53 -0400
In-Reply-To: <BLU0-SMTP255BD097115C7E52E264D41AC0A0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nathan Hintz <nlhintz@hotmail.com>
Date: Tue, 29 Oct 2013 19:32:01 -0700

> Don't update the slot in "bgmac_dma_rx_skb_for_slot" unless both the
> skb alloc and dma mapping are successful; and free the newly allocate=
d
> skb if a dma mapping error occurs.  This relieves the caller of the n=
eed
> to deduce/execute the appropriate cleanup action required when an err=
or
> occurs.
>=20
> Signed-off-by: Nathan Hintz <nlhintz@hotmail.com>
> Acked-by: Rafa=A9=A9 Mi=A9=A9ecki <zajec5@gmail.com>

Applied, thanks.
