From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] unix: account skb memory to receiving socket's sk_rmem_alloc on sending
Date: Sun, 10 Mar 2013 05:40:43 +0100
Message-ID: <20130310044043.GB2709@order.stressinduktion.org>
References: <20130204231414.GD6898@order.stressinduktion.org> <20130309214333.GI28531@order.stressinduktion.org> <1362889861.4051.15.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, yannick@koehler.name,
	xiyou.wangcong@gmail.com, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:54256 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751959Ab3CJEkp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Mar 2013 23:40:45 -0500
Content-Disposition: inline
In-Reply-To: <1362889861.4051.15.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 10, 2013 at 05:31:01AM +0100, Eric Dumazet wrote:
> On Sat, 2013-03-09 at 22:43 +0100, Hannes Frederic Sowa wrote:
> 
> > I had this patch left from the last net-next submission timeframe. In
> > the meantime I did some updates I would love to have a review on. It
> > e.g. includes poll handling now.
> > 
> > This patch lacks documentation updates for max_dgram_qlen. I'll update
> > the documentation on the next submission.
> > 
> > Btw, iproute from current git has the ability to report socket memory for
> > unix domain sockets, too. So these changes should be better observable.
> 
> I am busy this week attending Netfilter Workshop in Copenhagen.
> 
> Do you have a user test program ?

I used a couple of perl scripts. I'll bring them in shape and will post them
here, hopefully tomorrow.

Have great fun in Copenhagen!
