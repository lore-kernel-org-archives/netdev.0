From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] net_sched: do not broadcast RTM_GETTFILTER result
Date: Wed, 12 Oct 2016 09:36:18 -0700
Message-ID: <CAM_iQpWDwwo+DEi2aytoAnTHWKWeTRiMZqXfvaB7=T9eOnvR-w@mail.gmail.com>
References: <1476069955.28155.292.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:35633 "EHLO
        mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754888AbcJLQgx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 12:36:53 -0400
Received: by mail-io0-f172.google.com with SMTP id i202so56152792ioi.2
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2016 09:36:39 -0700 (PDT)
In-Reply-To: <1476069955.28155.292.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 9, 2016 at 8:25 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> +       if (unicast)
> +               return netlink_unicast(net->rtnl, skb, portid, MSG_DONTWAIT);

Nit: rtnl_unicast() is simpler.
