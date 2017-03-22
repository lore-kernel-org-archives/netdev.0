From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net] tcp: initialize icsk_ack.lrcvtime at session start time
Date: Wed, 22 Mar 2017 14:13:57 -0400
Message-ID: <CADVnQymzFmP6ZAMjphr2bVxf7vYrE0tvpNvkxQv07fu6XTBbzw@mail.gmail.com>
References: <1490195421.16816.157.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:36313 "EHLO
        mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935279AbdCVSO3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 14:14:29 -0400
Received: by mail-oi0-f45.google.com with SMTP id r203so49583791oib.3
        for <netdev@vger.kernel.org>; Wed, 22 Mar 2017 11:14:28 -0700 (PDT)
In-Reply-To: <1490195421.16816.157.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 22, 2017 at 11:10 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> icsk_ack.lrcvtime has a 0 value at socket creation time.
>
> tcpi_last_data_recv can have bogus value if no payload is ever received.
>
> This patch initializes icsk_ack.lrcvtime for active sessions
> in tcp_finish_connect(), and for passive sessions in
> tcp_create_openreq_child()
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---

Thanks, Eric!

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
