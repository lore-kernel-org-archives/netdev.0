From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] netem: fix a use after free
Date: Mon, 20 Jun 2016 15:53:42 -0700
Message-ID: <CAM_iQpXCpV8agcKFnc2rKjFX+LGBcs+icYzvPd16qY_xZcOTMw@mail.gmail.com>
References: <1466459980.6850.20.camel@edumazet-glaptop3.roam.corp.google.com> <1466460043.6850.21.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f181.google.com ([209.85.161.181]:35525 "EHLO
	mail-yw0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932381AbcFTWyU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 18:54:20 -0400
Received: by mail-yw0-f181.google.com with SMTP id l125so37119059ywb.2
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 15:54:02 -0700 (PDT)
In-Reply-To: <1466460043.6850.21.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 20, 2016 at 3:00 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> If the packet was dropped by lower qdisc, then we must not
> access it later.
>
> Save qdisc_pkt_len(skb) in a temp variable.
>
> Fixes: 2ccccf5fb43f ("net_sched: update hierarchical backlog too")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: WANG Cong <xiyou.wangcong@gmail.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: Stephen Hemminger <stephen@networkplumber.org>


Acked-by: Cong Wang <xiyou.wangcong@gmail.com>
