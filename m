From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH net-next v4 0/3] netpoll: add IPv6 support
Date: Tue, 08 Jan 2013 11:55:51 +0800
Message-ID: <1357617351.3544.8.camel@cr0>
References: <1357543036-15492-1-git-send-email-amwang@redhat.com>
	 <20130107.194621.1068055780988116658.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22519 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750785Ab3AHDz5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jan 2013 22:55:57 -0500
In-Reply-To: <20130107.194621.1068055780988116658.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-01-07 at 19:46 -0800, David Miller wrote:
> From: Cong Wang <amwang@redhat.com>
> Date: Mon,  7 Jan 2013 15:17:13 +0800
> 
> > v4: remove ndisc_parse_options(), ignore ICMP options there
> >     make udp6_csum_init() inline so that we don't rely on IPV6=y
> >     fix a conflict with Jiri's patchset
> 
> Where did I say to inline this function?
> 
> I said to put it into a seperate static library that gets
> linked into the kernel statically, regardless of whether
> IPV6 is 'm' or 'y'.
> 
> I've said this _3_ times and I'm really starting to get
> frustrated with the fact that you can't seem to read what
> I write.
> 
> What part of the "obj-y +=" rules in net/ipv6/Makefile
> are you unable to see?

I knew.

Our goal is to make it work for IPV6=m, so why inline is not a solution
while putting it into a static library is? udp6_csum_init() is not a big
function, so I see no reason why it can't be inlined.

And AFAIK, udp6_csum_init() can't fit into any of these obj-y files in
net/ipv6/.

Am I still missing anything?

Thanks.
