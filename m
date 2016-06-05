From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH v2 net] fq_codel: fix NET_XMIT_CN behavior
Date: Sun, 5 Jun 2016 13:30:40 -0700
Message-ID: <CAM_iQpVORpFx_xx67gYT_3jXfWAuqkMmR03R9VJv1TrcqH4W8A@mail.gmail.com>
References: <1465062227.2968.7.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160604190301.GA8857@strlen.de> <1465070113.2968.18.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Westphal <fw@strlen.de>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stas Nichiporovich <stasn77@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f173.google.com ([209.85.161.173]:34124 "EHLO
	mail-yw0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751211AbcFEUbB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2016 16:31:01 -0400
Received: by mail-yw0-f173.google.com with SMTP id c127so124267592ywb.1
        for <netdev@vger.kernel.org>; Sun, 05 Jun 2016 13:31:00 -0700 (PDT)
In-Reply-To: <1465070113.2968.18.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 4, 2016 at 12:55 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> My prior attempt to fix the backlogs of parents failed.
>
> If we return NET_XMIT_CN, our parents wont increase their backlog,
> so our qdisc_tree_reduce_backlog() should take this into account.
>

Acked-by: Cong Wang <xiyou.wangcong@gmail.com>
