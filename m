From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next 4/4] net/sched: act_mirred: Implement ingress actions
Date: Sat, 24 Sep 2016 16:50:56 -0700
Message-ID: <CAM_iQpX=CzjO+AeivaRUfvHruMQEmkXCuMt8S0Web3kNpmKAiQ@mail.gmail.com>
References: <1474550512-7552-1-git-send-email-shmulik.ladkani@gmail.com> <1474550512-7552-5-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Eric Dumazet <edumazet@google.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33746 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754493AbcIXXvS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 24 Sep 2016 19:51:18 -0400
Received: by mail-it0-f65.google.com with SMTP id x192so3064015itb.0
        for <netdev@vger.kernel.org>; Sat, 24 Sep 2016 16:51:17 -0700 (PDT)
In-Reply-To: <1474550512-7552-5-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 22, 2016 at 6:21 AM, Shmulik Ladkani
<shmulik.ladkani@ravellosystems.com> wrote:
> From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
>
> Up until now, 'action mirred' supported only egress actions (either
> TCA_EGRESS_REDIR or TCA_EGRESS_MIRROR).
>
> This patch implements the corresponding ingress actions
> TCA_INGRESS_REDIR and TCA_INGRESS_MIRROR.
>
> This allows attaching filters whose target is to hand matching skbs into
> the rx processing of a specified device.

I like this idea, this idea actually came to my mind when we
tried to redirect packets from eth0 to veth device in containers.
I remember I already brought this up to Jamal before (either personally
or publicly), but I forgot why I stopped.

This would reduce some latency for our Mesos containers, we
would just skip one veth TX in our scenario.
