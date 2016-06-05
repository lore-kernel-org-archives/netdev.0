From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH v2 net] fq_codel: fix NET_XMIT_CN behavior
Date: Sun, 5 Jun 2016 16:30:05 -0700
Message-ID: <CAM_iQpXMwT20nhWW4Pd2yy6nkeXkSNdxV9wAEGzGd22PcyePmg@mail.gmail.com>
References: <1465062227.2968.7.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160604190301.GA8857@strlen.de> <1465070113.2968.18.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpVORpFx_xx67gYT_3jXfWAuqkMmR03R9VJv1TrcqH4W8A@mail.gmail.com>
 <1465160087.2968.51.camel@edumazet-glaptop3.roam.corp.google.com> <1465160123.2968.52.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Westphal <fw@strlen.de>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stas Nichiporovich <stasn77@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f176.google.com ([209.85.161.176]:35474 "EHLO
	mail-yw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751897AbcFEXa0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2016 19:30:26 -0400
Received: by mail-yw0-f176.google.com with SMTP id o16so126372860ywd.2
        for <netdev@vger.kernel.org>; Sun, 05 Jun 2016 16:30:26 -0700 (PDT)
In-Reply-To: <1465160123.2968.52.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 5, 2016 at 1:55 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sun, 2016-06-05 at 13:54 -0700, Eric Dumazet wrote:
>
>> BTW, we might need a similar fix in sch_fq.c
>
> I meant sch_sfq.c
>

Potentially all of the following:

net/sched/sch_choke.c:  return NET_XMIT_CN;
net/sched/sch_fifo.c:   return NET_XMIT_CN;
net/sched/sch_generic.c:        return NET_XMIT_CN;
net/sched/sch_gred.c:   return NET_XMIT_CN;
net/sched/sch_hhf.c:            return NET_XMIT_CN;
net/sched/sch_red.c:    return NET_XMIT_CN;
net/sched/sch_sfb.c:    return NET_XMIT_CN;
net/sched/sch_sfq.c:            return NET_XMIT_CN;
