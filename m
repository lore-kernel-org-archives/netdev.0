From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bgmac: pass received packet to the netif instead of
 copying it
Date: Wed, 30 Oct 2013 16:58:45 -0400 (EDT)
Message-ID: <20131030.165845.354006604111494289.davem@davemloft.net>
References: <1383116400-29905-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, openwrt-devel@lists.openwrt.org,
	nlhintz@hotmail.com
To: zajec5@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34260 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797Ab3J3U6r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 16:58:47 -0400
In-Reply-To: <1383116400-29905-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Rafa=A9=A9 Mi=A9=A9ecki <zajec5@gmail.com>
Date: Wed, 30 Oct 2013 08:00:00 +0100

> Copying whole packets with skb_copy_from_linear_data_offset is a pret=
ty
> bad idea. CPU was spending time in __copy_user_common and network
> performance was lower. With the new solution iperf-measured speed
> increased from 116Mb/s to 134Mb/s.
>=20
> Signed-off-by: Rafa=A9=A9 Mi=A9=A9ecki <zajec5@gmail.com>
> ---
> Changes since [RFC TRY#2]:
> 1) Fixed arguments alignment
> 2) Dropped code fixing old slot in case of bgmac_dma_rx_skb_for_slot
> failure. Thanks to Nathan patch bgmac_dma_rx_skb_for_slot doesn't
> change anything in slot in case it failed somewhere.

Looks good, applied to net-next, thanks.
