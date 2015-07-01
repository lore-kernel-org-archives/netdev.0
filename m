From: Nicolae Rosia <nicolae.rosia@gmail.com>
Subject: Re: [PATCH net-next] net: macb: replace literal constant with NET_IP_ALIGN
Date: Wed, 1 Jul 2015 18:53:13 +0300
Message-ID: <CAH=tA9HHqQMhs5_qdc63BsT1BW0jvmoEChbsgzvn-LKqbUt1zQ@mail.gmail.com>
References: <5592D105.7080006@certsign.ro> <1435748191.4110.127.camel@edumazet-glaptop2.roam.corp.google.com>
 <5593EB38.5050000@certsign.ro> <1435758289.4110.130.camel@edumazet-glaptop2.roam.corp.google.com>
 <5593F956.4020300@certsign.ro> <1435764834.4110.132.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nicolae Rosia <nicolae.rosia@certsign.ro>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:33724 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750935AbbGAPxy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2015 11:53:54 -0400
Received: by laar3 with SMTP id r3so43781235laa.0
        for <netdev@vger.kernel.org>; Wed, 01 Jul 2015 08:53:52 -0700 (PDT)
In-Reply-To: <1435764834.4110.132.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 1, 2015 at 6:33 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
[...]
> This only matters in terms of few nano seconds per packet, so for 10Gb+
> NIC anyway. Absolute noise for most NIC.
>
I'll give it a try and benchmark.
I achieved a huge speedup by moving TX into napi [0], but my hardware doesn't
support multiple TX queues and I can't test that situation.

> Yes, but main question is : Do you have the hardware to test your
> changes ?
Yes, I have a Xilinx ZC706 board with a Zynq7 XC7Z045 processor [1]

[0] https://patchwork.ozlabs.org/patch/488949/
[1] http://www.xilinx.com/products/boards-and-kits/ek-z7-zc706-g.html
