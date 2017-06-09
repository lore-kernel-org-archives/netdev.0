From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net-next] bpf: Remove duplicate tcp_filter hook in ipv6
Date: Fri, 9 Jun 2017 14:12:45 -0700
Message-ID: <CANn89i+WfuZXv6RBaOcriVG2ieTqAD2jQqXcf7wS4__q9EoaBA@mail.gmail.com>
References: <1497035857-9927-1-git-send-email-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Lorenzo Colitti <lorenzo@google.com>,
        Chenbo Feng <fengc@google.com>
To: Chenbo Feng <chenbofeng.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f173.google.com ([209.85.213.173]:34683 "EHLO
        mail-yb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751739AbdFIVMv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 17:12:51 -0400
Received: by mail-yb0-f173.google.com with SMTP id 4so18157082ybl.1
        for <netdev@vger.kernel.org>; Fri, 09 Jun 2017 14:12:51 -0700 (PDT)
In-Reply-To: <1497035857-9927-1-git-send-email-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 9, 2017 at 12:17 PM, Chenbo Feng
<chenbofeng.kernel@gmail.com> wrote:
> From: Chenbo Feng <fengc@google.com>
>
> There are two tcp_filter hooks in tcp_ipv6 ingress path currently.
> One is at tcp_v6_rcv and another is in tcp_v6_do_rcv. It seems the
> tcp_filter() call inside tcp_v6_do_rcv is redundent and some packet
> will be filtered twice in this situation. This will cause trouble
> when using eBPF filters to account traffic data.
>
> Signed-off-by: Chenbo Feng <fengc@google.com>
> Acked-by: Eric Dumazet <edumazet@google.com>
> ---
>  net/ipv6/tcp_ipv6.c | 3 ---
>  1 file changed, 3 deletions(-)

Yes, this is the patch I agreed on ;)

Thanks
