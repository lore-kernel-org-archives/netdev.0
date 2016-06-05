From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net] fq_codel: fix NET_XMIT_CN behavior
Date: Sun, 05 Jun 2016 13:54:47 -0700
Message-ID: <1465160087.2968.51.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1465062227.2968.7.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160604190301.GA8857@strlen.de>
	 <1465070113.2968.18.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAM_iQpVORpFx_xx67gYT_3jXfWAuqkMmR03R9VJv1TrcqH4W8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stas Nichiporovich <stasn77@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33187 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751906AbcFEUyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2016 16:54:50 -0400
Received: by mail-pf0-f176.google.com with SMTP id y124so500052pfy.0
        for <netdev@vger.kernel.org>; Sun, 05 Jun 2016 13:54:50 -0700 (PDT)
In-Reply-To: <CAM_iQpVORpFx_xx67gYT_3jXfWAuqkMmR03R9VJv1TrcqH4W8A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-06-05 at 13:30 -0700, Cong Wang wrote:
> On Sat, Jun 4, 2016 at 12:55 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > From: Eric Dumazet <edumazet@google.com>
> >
> > My prior attempt to fix the backlogs of parents failed.
> >
> > If we return NET_XMIT_CN, our parents wont increase their backlog,
> > so our qdisc_tree_reduce_backlog() should take this into account.
> >
> 
> Acked-by: Cong Wang <xiyou.wangcong@gmail.com>

BTW, we might need a similar fix in sch_fq.c
