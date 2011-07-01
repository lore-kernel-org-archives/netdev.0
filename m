From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH 0/2] netpoll: Trivial updates
Date: Fri, 01 Jul 2011 11:49:23 +0800
Message-ID: <4E0D43C3.5090502@redhat.com>
References: <cover.1309482314.git.joe@perches.com>	 <4E0D3E80.5080209@redhat.com> <1309491349.7277.22.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1309491349.7277.22.camel@Joe-Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2011=E5=B9=B407=E6=9C=8801=E6=97=A5 11:35, Joe Perches =E5=86=
=99=E9=81=93:
>
>> BTW, you can kill the export of netpoll_send_skb_on_dev() too.
>
> Not too sure about that.
>
> It's used in netpoll.h by netpoll_send_skb.
> It could be called from anywhere.
> It's currently called/used by bonding.h.

% git grep netpoll_send_skb_on_dev .
include/linux/netpoll.h:void netpoll_send_skb_on_dev(struct netpoll *np=
, struct sk_buff *skb,
include/linux/netpoll.h:        netpoll_send_skb_on_dev(np, skb, np->de=
v);
net/core/netpoll.c:void netpoll_send_skb_on_dev(struct netpoll *np, str=
uct sk_buff *skb,
net/core/netpoll.c:EXPORT_SYMBOL(netpoll_send_skb_on_dev);

No modules use it...
