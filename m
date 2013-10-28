From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [RFC TRY#2][PATCH] bgmac: pass received packet to the netif
 instead of copying it
Date: Mon, 28 Oct 2013 21:36:47 +0100
Message-ID: <CACna6rxnpMQGCKPsc7jwOLZO7PLKpjRgor48Xoqp-RxT8h_9uA@mail.gmail.com>
References: <1382982142-16876-1-git-send-email-zajec5@gmail.com>
	<20131028.162858.1940229138245324914.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>,
	OpenWrt Development List <openwrt-devel@lists.openwrt.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:47182 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756240Ab3J1Ugr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 16:36:47 -0400
Received: by mail-oa0-f46.google.com with SMTP id g12so4210361oah.19
        for <netdev@vger.kernel.org>; Mon, 28 Oct 2013 13:36:47 -0700 (PDT)
In-Reply-To: <20131028.162858.1940229138245324914.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/10/28 David Miller <davem@davemloft.net>:
> However, this is not:
>
>> +                     /* Unmap old skb, we'll pass it to the netfif =
*/
>> +                     dma_unmap_single(dma_dev, old_dma_addr,
>> +                                             BGMAC_RX_BUF_SIZE,
>> +                                             DMA_FROM_DEVICE);
>> +

Oh, sorry for that. I had to copy & paste it in some silly way... Will =
fix that!

--=20
Rafa=C5=82
