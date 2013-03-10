From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC] unix: account skb memory to receiving socket's
 sk_rmem_alloc on sending
Date: Sun, 10 Mar 2013 05:31:01 +0100
Message-ID: <1362889861.4051.15.camel@edumazet-glaptop>
References: <20130204231414.GD6898@order.stressinduktion.org>
	 <20130309214333.GI28531@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yannick@koehler.name,
	xiyou.wangcong@gmail.com, davem@davemloft.net
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:62909 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751959Ab3CJEbF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Mar 2013 23:31:05 -0500
Received: by mail-ee0-f41.google.com with SMTP id c13so1707257eek.0
        for <netdev@vger.kernel.org>; Sat, 09 Mar 2013 20:31:04 -0800 (PST)
In-Reply-To: <20130309214333.GI28531@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-03-09 at 22:43 +0100, Hannes Frederic Sowa wrote:

> I had this patch left from the last net-next submission timeframe. In
> the meantime I did some updates I would love to have a review on. It
> e.g. includes poll handling now.
> 
> This patch lacks documentation updates for max_dgram_qlen. I'll update
> the documentation on the next submission.
> 
> Btw, iproute from current git has the ability to report socket memory for
> unix domain sockets, too. So these changes should be better observable.

I am busy this week attending Netfilter Workshop in Copenhagen.

Do you have a user test program ?
