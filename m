From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net] tcp: fix 0 divide in __tcp_select_window()
Date: Wed, 1 Feb 2017 11:41:49 -0500
Message-ID: <CADVnQymvZ4Rvdx3mG=jA_9RMs79O5-r5quroN6Kjzso0WsUvgg@mail.gmail.com>
References: <1485966833.6360.149.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:35279 "EHLO
        mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751114AbdBAQmV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 11:42:21 -0500
Received: by mail-oi0-f47.google.com with SMTP id j15so237123195oih.2
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2017 08:42:20 -0800 (PST)
In-Reply-To: <1485966833.6360.149.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 1, 2017 at 11:33 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> From: Eric Dumazet <edumazet@google.com>
>
> syszkaller fuzzer was able to trigger a divide by zero, when
> TCP window scaling is not enabled.
>
> SO_RCVBUF can be used not only to increase sk_rcvbuf, also
> to decrease it below current receive buffers utilization.
>
> If mss is negative or 0, just return a zero TCP window.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dmitry Vyukov  <dvyukov@google.com>
> ---

Acked-by: Neal Cardwell <ncardwell@google.com>

Thanks, Eric!

neal
