From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 4/8] net/mlx4_en: Add __GFP_COLD gfp flags in alloc_pages
Date: Fri, 31 Oct 2014 00:49:45 +0200
Message-ID: <CAJ3xEMiVTDY5diY=tpcHbOdmqseFyajrcfo9Gh3Cd=kHqYQ-tg@mail.gmail.com>
References: <1414685216-28907-1-git-send-email-ogerlitz@mellanox.com>
	<1414685216-28907-5-git-send-email-ogerlitz@mellanox.com>
	<1414689333.9028.0.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Shani Michaeli <shanim@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:58397 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161345AbaJ3Wtq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 18:49:46 -0400
Received: by mail-oi0-f51.google.com with SMTP id g201so4795008oib.38
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2014 15:49:45 -0700 (PDT)
In-Reply-To: <1414689333.9028.0.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 30, 2014 at 7:15 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> @@ -54,7 +54,7 @@ static int mlx4_alloc_pages(struct mlx4_en_priv *priv,
>>       dma_addr_t dma;
>>
>>       for (order = MLX4_EN_ALLOC_PREFER_ORDER; ;) {
>> -             gfp_t gfp = _gfp;
>> +             gfp_t gfp = _gfp | __GFP_COLD;

> This should be set by callers, to avoid extra code
> GFP_ATOMIC | __GFP_COLD
> or
> GFP_KERNEL | __GFP_COLD

I guess we can do that, sure.
