From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] netpoll: Trivial updates
Date: Fri, 01 Jul 2011 00:06:46 -0700 (PDT)
Message-ID: <20110701.000646.268663722441785795.davem@davemloft.net>
References: <4E0D3E80.5080209@redhat.com>
	<1309491349.7277.22.camel@Joe-Laptop>
	<4E0D43C3.5090502@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4E0D43C3.5090502@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cong Wang <amwang@redhat.com>
Date: Fri, 01 Jul 2011 11:49:23 +0800

> 于 2011年07月01日 11:35, Joe Perches 写道:
>>
>>> BTW, you can kill the export of netpoll_send_skb_on_dev() too.
>>
>> Not too sure about that.
>>
>> It's used in netpoll.h by netpoll_send_skb.
>> It could be called from anywhere.
>> It's currently called/used by bonding.h.
> 
> % git grep netpoll_send_skb_on_dev .
> include/linux/netpoll.h:void netpoll_send_skb_on_dev(struct netpoll
> *np, struct sk_buff *skb,
> include/linux/netpoll.h: netpoll_send_skb_on_dev(np, skb, np->dev);
> net/core/netpoll.c:void netpoll_send_skb_on_dev(struct netpoll *np,
> struct sk_buff *skb,
> net/core/netpoll.c:EXPORT_SYMBOL(netpoll_send_skb_on_dev);
> 
> No modules use it...

Right, this is a relic that bonding was using at one point
in the past but it no longer does.
