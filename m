From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 4/4] net/sched: act_mirred: Implement ingress
 actions
Date: Thu, 22 Sep 2016 19:40:15 -0400
Message-ID: <4387324a-de66-aa1b-86f0-1a9a2f8294f5@mojatatu.com>
References: <1474550512-7552-1-git-send-email-shmulik.ladkani@gmail.com>
 <1474550512-7552-5-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: WANG Cong <xiyou.wangcong@gmail.com>,
        Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:34552 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933539AbcIVXkR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 19:40:17 -0400
Received: by mail-io0-f195.google.com with SMTP id y139so6147512ioy.1
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 16:40:17 -0700 (PDT)
In-Reply-To: <1474550512-7552-5-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-22 09:21 AM, Shmulik Ladkani wrote:
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
>

Thank you for doing this. There was something that made me remove
initial support for this feature - I am blanking out right now but
will find my notes and give more details. It may be around preventing
loops maybe. If that was the thought then:
I am just wondering is there a use case for a packet that is redirected
from egress ethx to ingress of ethy that then requires ingress of ethy
classify? Otherwise you could just set the "dont classify" flag.
i.e SET_TC_NCLS()

cheers,
jamal
