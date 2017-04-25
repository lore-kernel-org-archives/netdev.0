From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next 02/10] tcp: do not pass timestamp to tcp_rack_detect_loss()
Date: Tue, 25 Apr 2017 13:51:12 -0400
Message-ID: <CADVnQynWZGux7_R28bd8Jkjw=DJKVJ3BsH6=kbVWgALw_tJLLg@mail.gmail.com>
References: <20170425171541.3417-1-edumazet@google.com> <20170425171541.3417-3-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:34909 "EHLO
        mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1946448AbdDYRvn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 13:51:43 -0400
Received: by mail-oi0-f44.google.com with SMTP id j201so180894740oih.2
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 10:51:43 -0700 (PDT)
In-Reply-To: <20170425171541.3417-3-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 25, 2017 at 1:15 PM, Eric Dumazet <edumazet@google.com> wrote:
> We can use tp->tcp_mstamp as it contains a recent timestamp.
>
> This removes a call to skb_mstamp_get() from tcp_rack_reo_timeout()
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Acked-by: Soheil Hassas Yeganeh <soheil@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
