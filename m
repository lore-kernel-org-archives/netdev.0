From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net-next 0/4] tcp: tsq: performance series
Date: Fri, 2 Dec 2016 12:57:06 -0800
Message-ID: <CANn89iK1FJ9mMYE+fQYrtDTJ4ohsuMSv+P9sJPnSWq9RqdQ3gA@mail.gmail.com>
References: <1480703159-2327-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:36192 "EHLO
        mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751729AbcLBVD2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 16:03:28 -0500
Received: by mail-io0-f180.google.com with SMTP id m5so365712179ioe.3
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 13:03:27 -0800 (PST)
In-Reply-To: <1480703159-2327-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 2, 2016 at 10:25 AM, Eric Dumazet <edumazet@google.com> wrote:
> Under very high TX stress, CPU handling NIC TX completions can spend
> considerable amount of cycles handling TSQ (TCP Small Queues) logic.
>
> This patch series avoids some atomic operations, but more important
> patch is the 3rd one, allowing other cpus processing ACK packets and
> calling tcp_write_xmit() to grab TCP_TSQ_DEFERRED so that
> tcp_tasklet_func() can skip already processed sockets.
>
> This avoid lots of lock acquisitions and cache lines accesses,
> particularly under load.
>

Please do not merge this version.

I probably messed something, I need to make more tests.

Thanks.
