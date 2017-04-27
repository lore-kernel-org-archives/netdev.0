From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] tcp: tcp_rack_reo_timeout() must update tp->tcp_mstamp
Date: Thu, 27 Apr 2017 10:10:22 -0400
Message-ID: <CADVnQykZguANOQSznrE6fp0YfyUgK1YbVG99ATtyFVqZFnLS-w@mail.gmail.com>
References: <1493266255.6453.103.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:34672 "EHLO
        mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751184AbdD0OKx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 10:10:53 -0400
Received: by mail-oi0-f44.google.com with SMTP id x184so38956551oia.1
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 07:10:53 -0700 (PDT)
In-Reply-To: <1493266255.6453.103.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 27, 2017 at 12:10 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> I wrongly assumed tp->tcp_mstamp was up to date at the time
> tcp_rack_reo_timeout() was called.
>
> It is not true, since we only update tcp->tcp_mstamp when receiving
> a packet (as initially done in commit 69e996c58a35 ("tcp: add
> tp->tcp_mstamp field")
>
> tcp_rack_reo_timeout() being called by a timer and not an incoming
> packet, we need to refresh tp->tcp_mstamp
>
> Fixes: 7c1c7308592f ("tcp: do not pass timestamp to tcp_rack_detect_loss()")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Soheil Hassas Yeganeh <soheil@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

Thanks!

neal
