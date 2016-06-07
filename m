From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next 2/2] net: sched: do not acquire qdisc spinlock in
 qdisc/class stats dump
Date: Tue, 7 Jun 2016 16:39:20 -0700
Message-ID: <CAM_iQpXvynRVFW3e=sojVp1njBhq4GyTY1zgdUMoD2KqicBvqw@mail.gmail.com>
References: <1465231036-10674-1-git-send-email-edumazet@google.com>
 <1465231036-10674-3-git-send-email-edumazet@google.com> <CAM_iQpURiYyBqpKG=u4qvbgToe4kQd4=8d_N0ohbfG_cONw_8Q@mail.gmail.com>
 <1465257199.24873.10.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Kevin Athey <kda@google.com>,
	Xiaotian Pei <xiaotian@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:33814 "EHLO
	mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751632AbcFGXjl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 19:39:41 -0400
Received: by mail-yw0-f195.google.com with SMTP id j74so24841889ywg.1
        for <netdev@vger.kernel.org>; Tue, 07 Jun 2016 16:39:41 -0700 (PDT)
In-Reply-To: <1465257199.24873.10.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 6, 2016 at 4:53 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Really sounds overkill to care about these, as probably no one needs to
> get a 'consistent view of all these counters in a snapshot'.
>
> Even as of today, the qlen/backlog pair is wrong. No one ever used these
> values in an SNMP agent.
>
> Note that qlen/backlog is changed both by enqueue/dequeue, so the
> seqcount protection would not work.

I see.

>
> With the percpu stats thing, stats can not be fetched in a 'consistent'
> way.

Fair enough.

Thanks!
