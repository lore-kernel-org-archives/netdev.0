From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net-next] ipv6: Initial skb->dev and skb->protocol in ip6_output
Date: Fri, 9 Jun 2017 14:11:40 -0700
Message-ID: <CANn89iJwxmiU2HN4cG42r74_2z4pk+t1pD0nWaHUgJFGffgM=A@mail.gmail.com>
References: <1497035168-9093-1-git-send-email-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Lorenzo Colitti <lorenzo@google.com>,
        Chenbo Feng <fengc@google.com>
To: Chenbo Feng <chenbofeng.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f179.google.com ([209.85.161.179]:33617 "EHLO
        mail-yw0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751545AbdFIVLl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 17:11:41 -0400
Received: by mail-yw0-f179.google.com with SMTP id 63so24203888ywr.0
        for <netdev@vger.kernel.org>; Fri, 09 Jun 2017 14:11:41 -0700 (PDT)
In-Reply-To: <1497035168-9093-1-git-send-email-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 9, 2017 at 12:06 PM, Chenbo Feng
<chenbofeng.kernel@gmail.com> wrote:
> From: Chenbo Feng <fengc@google.com>
>
> Move the initialization of skb->dev and skb->protocol from
> ip6_finish_output2 to ip6_output. This can make the skb->dev and
> skb->protocol information avalaible to the CGROUP eBPF filter.
>
> Signed-off-by: Chenbo Feng <fengc@google.com>
> Acked-by: Eric Dumazet <edumazet@google.com>
> ---

Arg, you mixed my Acked-by for your other patch :/
