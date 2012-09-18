From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next] mlx4: use dev_kfree_skb() instead of dev_kfree_skb_any()
Date: Tue, 18 Sep 2012 22:58:41 +0300
Message-ID: <CAJZOPZ+=B81_mv32L7o6QSULTDZbiAGi85PiiFvc9da0eb9HqA@mail.gmail.com>
References: <1347866974.26523.53.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>, Ying Cai <ycai@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:58849 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754501Ab2IRT6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2012 15:58:42 -0400
Received: by ieak13 with SMTP id k13so354781iea.19
        for <netdev@vger.kernel.org>; Tue, 18 Sep 2012 12:58:41 -0700 (PDT)
In-Reply-To: <1347866974.26523.53.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 17, 2012 at 10:29 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Since commit e22979d96a5 (mlx4_en: Moving to Interrupts for TX
> completions), we no longer can free TX skb from hard IRQ, but only from
> normal softirq or process context.
>
> Therefore, we can directly call dev_kfree_skb() from
> mlx4_en_free_tx_desc() like other conventional NAPI drivers.

Hi Eric,

The team is all off till tomorrow, we will look and get back to you

Or.
