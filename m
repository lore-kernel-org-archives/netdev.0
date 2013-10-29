From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH] bgmac: don't update slot on skb alloc/dma mapping error
Date: Tue, 29 Oct 2013 07:52:58 +0100
Message-ID: <CACna6rzxt2QMtLfD84pw7EtYqg1Qva4ah83hVQOKpeKy72bd5w@mail.gmail.com>
References: <BLU0-SMTP119F7A71B34291D1CC2486BAC090@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>
To: Nathan Hintz <nlhintz@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f50.google.com ([209.85.219.50]:60244 "EHLO
	mail-oa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752311Ab3J2Gw7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 02:52:59 -0400
Received: by mail-oa0-f50.google.com with SMTP id j6so4746702oag.37
        for <netdev@vger.kernel.org>; Mon, 28 Oct 2013 23:52:58 -0700 (PDT)
In-Reply-To: <BLU0-SMTP119F7A71B34291D1CC2486BAC090@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/10/29 Nathan Hintz <nlhintz@hotmail.com>:
> Don't update the slot in "bgmac_dma_rx_skb_for_slot" unless both the
> skb alloc and dma mapping are successful; and free the newly allocate=
d
> skb if a dma mapping error occurs.  This will prevent an skb leak upo=
n
> returning when an error occurs.

In case of bgmac_dma_rx_skb_for_slot failure we're giving up anyway
(and freeing everything), but with your patch code is simpler to
understand, so I'm OK with that.

Acked-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>

--=20
Rafa=C5=82
