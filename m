From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] net_sched: fix pfifo_head_drop behavior vs backlog
Date: Sun, 12 Jun 2016 20:48:00 -0700
Message-ID: <CAM_iQpXzZRwkYexMUAeAQVncFrSBW1UM07+P6grzP3kX04ut_Q@mail.gmail.com>
References: <1465786885.7945.140.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f175.google.com ([209.85.161.175]:34742 "EHLO
	mail-yw0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933283AbcFMDsU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2016 23:48:20 -0400
Received: by mail-yw0-f175.google.com with SMTP id c72so115332534ywb.1
        for <netdev@vger.kernel.org>; Sun, 12 Jun 2016 20:48:20 -0700 (PDT)
In-Reply-To: <1465786885.7945.140.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 12, 2016 at 8:01 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> When the qdisc is full, we drop a packet at the head of the queue,
> queue the current skb and return NET_XMIT_CN
>
> Now we track backlog on upper qdiscs, we need to call
> qdisc_tree_reduce_backlog(), even if the qlen did not change.
>
> Fixes: 2ccccf5fb43f ("net_sched: update hierarchical backlog too")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: WANG Cong <xiyou.wangcong@gmail.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>


Acked-by: Cong Wang <xiyou.wangcong@gmail.com>
