From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next 01/10] tcp: add tp->tcp_mstamp field
Date: Tue, 25 Apr 2017 13:49:00 -0400
Message-ID: <CADVnQy=PLNSGSqptnAmhbxb5JM_WmUW3YtzSL-Nb1kFRTVS+kw@mail.gmail.com>
References: <20170425171541.3417-1-edumazet@google.com> <20170425171541.3417-2-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:35893 "EHLO
        mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1431850AbdDYRtb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 13:49:31 -0400
Received: by mail-oi0-f46.google.com with SMTP id w12so68857563oiw.3
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 10:49:31 -0700 (PDT)
In-Reply-To: <20170425171541.3417-2-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 25, 2017 at 1:15 PM, Eric Dumazet <edumazet@google.com> wrote:
> We want to use precise timestamps in TCP stack, but we do not
> want to call possibly expensive kernel time services too often.
>
> tp->tcp_mstamp is guaranteed to be updated once per incoming packet.
>
> We will use it in the following patches, removing specific
> skb_mstamp_get() calls, and removing ack_time from
> struct tcp_sacktag_state.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---

This series is great! Thanks, Eric!

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
