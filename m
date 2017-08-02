From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: remove extra POLL_OUT added for finished
 active connect()
Date: Wed, 02 Aug 2017 13:56:26 -0700
Message-ID: <1501707386.25002.21.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170802195958.21383-1-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:38366 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752535AbdHBU4a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 16:56:30 -0400
Received: by mail-wm0-f43.google.com with SMTP id m85so2465058wma.1
        for <netdev@vger.kernel.org>; Wed, 02 Aug 2017 13:56:29 -0700 (PDT)
In-Reply-To: <20170802195958.21383-1-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-08-02 at 15:59 -0400, Neal Cardwell wrote:
> Commit 45f119bf936b ("tcp: remove header prediction") introduced a
> minor bug: the sk_state_change() and sk_wake_async() notifications for
> a completed active connection happen twice: once in this new spot
> inside tcp_finish_connect() and once in the existing code in
> tcp_rcv_synsent_state_process() immediately after it calls
> tcp_finish_connect(). This commit remoes the duplicate POLL_OUT
> notifications.
> 
> Fixes: 45f119bf936b ("tcp: remove header prediction")
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Cc: Florian Westphal <fw@strlen.de>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> ---
>  net/ipv4/tcp_input.c | 5 -----
>  1 file changed, 5 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
