From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] net: reimplement completion_queue as a FIFO queue
Date: Mon, 26 Apr 2010 09:21:49 +0200
Message-ID: <1272266509.2346.2.camel@edumazet-laptop>
References: <1272258841.2069.968.camel@edumazet-laptop>
	 <q2w412e6f7f1004252244s3a5000eft850c2a5dc0fd72d1@mail.gmail.com>
	 <1272262154.2069.1032.camel@edumazet-laptop>
	 <20100425.232758.101478192.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xiaosuo@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:47893 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752704Ab0DZHVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 03:21:55 -0400
Received: by bwz19 with SMTP id 19so179449bwz.21
        for <netdev@vger.kernel.org>; Mon, 26 Apr 2010 00:21:53 -0700 (PDT)
In-Reply-To: <20100425.232758.101478192.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 25 avril 2010 =C3=A0 23:27 -0700, David Miller a =C3=A9crit=
 :

> No matter what is faster, we have to process packets in
> FIFO order, otherwise we get reordering within a flow
> which is to be absolutely avoided.

Hmm, completion queue is about freeing skb, and its name is misleading.

This queue is feed by dev_kfree_skb_irq() only



