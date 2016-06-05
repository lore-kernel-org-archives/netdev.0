From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v2 net] fq_codel: fix NET_XMIT_CN behavior
Date: Sun, 5 Jun 2016 09:03:10 -0400
Message-ID: <5754230E.3040508@mojatatu.com>
References: <1465062227.2968.7.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160604190301.GA8857@strlen.de>
 <1465070113.2968.18.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stas Nichiporovich <stasn77@gmail.com>,
	WANG Cong <xiyou.wangcong@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:34540 "EHLO
	mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750911AbcFENDN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2016 09:03:13 -0400
Received: by mail-io0-f180.google.com with SMTP id p194so119228536iod.1
        for <netdev@vger.kernel.org>; Sun, 05 Jun 2016 06:03:12 -0700 (PDT)
In-Reply-To: <1465070113.2968.18.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-06-04 03:55 PM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> My prior attempt to fix the backlogs of parents failed.
>
> If we return NET_XMIT_CN, our parents wont increase their backlog,
> so our qdisc_tree_reduce_backlog() should take this into account.
>
> v2: Florian Westphal pointed out that we could drop the packet,
> so we need to save qdisc_pkt_len(skb) in a temp variable before
> calling fq_codel_drop()
>
> Fixes: 9d18562a2278 ("fq_codel: add batch ability to fq_codel_drop()")
> Fixes: 2ccccf5fb43f ("net_sched: update hierarchical backlog too")
> Reported-by: Stas Nichiporovich <stasn77@gmail.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: WANG Cong <xiyou.wangcong@gmail.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
