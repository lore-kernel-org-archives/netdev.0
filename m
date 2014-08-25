From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/3] Basic deferred TX queue flushing infrastructure.
Date: Mon, 25 Aug 2014 15:37:54 -0700
Message-ID: <1409006274.3173.0.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140823.132811.751469424156827125.davem@davemloft.net>
	 <20140823.213839.1953243016141233125.davem@davemloft.net>
	 <CAHA+R7O_RSyKVNqcHXePbahvU+ayf77w61jos=G38M93okVWKw@mail.gmail.com>
	 <20140825.153146.2165451041039058085.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: cwang@twopensource.com, netdev@vger.kernel.org,
	therbert@google.com, jhs@mojatatu.com, hannes@stressinduktion.org,
	edumazet@google.com, jeffrey.t.kirsher@intel.com,
	rusty@rustcorp.com.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34513 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752917AbaHYWh4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 18:37:56 -0400
Received: by mail-pa0-f46.google.com with SMTP id lj1so21936143pab.19
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 15:37:56 -0700 (PDT)
In-Reply-To: <20140825.153146.2165451041039058085.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-08-25 at 15:31 -0700, David Miller wrote:

> It occurs to me that perhaps the thing to do is to pass sk_buff ** to
> dev_hard_start_xmit().

This was my suggestion ;)

int ret = dev_hard_start_xmit(skb, dev, txq);

->

int ret = dev_hard_start_xmit(&skb, dev, txq);
