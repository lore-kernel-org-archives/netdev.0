From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: [PATCH net-next 1/2] tcp: measure rwnd-limited time
Date: Wed, 7 Sep 2016 01:07:21 -0400
Message-ID: <CACSApvaZ=fz4AMpJYRCZY1CV93_-8fjJBQdys=huuXcKZzYzcg@mail.gmail.com>
References: <1473211961-107223-1-git-send-email-francisyyan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>
To: "Francis Y. Yan" <francisyyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:33382 "EHLO
        mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750820AbcIGFID (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 01:08:03 -0400
Received: by mail-oi0-f50.google.com with SMTP id y2so11074131oie.0
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2016 22:08:02 -0700 (PDT)
In-Reply-To: <1473211961-107223-1-git-send-email-francisyyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 6, 2016 at 9:32 PM, Francis Y. Yan <francisyyan@gmail.com> wrote:
> This patch measures the total time when TCP transmission is limited
> by receiver's advertised window (rwnd), and exports it in tcp_info as
> tcpi_rwnd_limited.
>
> The rwnd-limited time is defined as the period when the next segment
> to send by TCP cannot fit into rwnd. To measure it, we record the last
> timestamp when limited by rwnd (rwnd_limited_ts) and the total
> rwnd-limited time (rwnd_limited) in tcp_sock.
>
> Then we export the total rwnd-limited time so far in tcp_info, where
> by so far, we mean that if TCP transmission is still being limited by
> rwnd, the time interval since rwnd_limited_ts needs to be counted as
> well; otherwise, we simply export rwnd_limited.
>
> It is worth noting that we also have to add a new sequence counter
> (seqcnt) in tcp_sock to carefully handle tcp_info's reading of
> rwnd_limited_ts and rwnd_limited in order to get a consistent snapshot
> of both variables together.
>
> Signed-off-by: Francis Y. Yan <francisyyan@gmail.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Acked-by: Soheil Hassas Yeganeh <soheil@google.com>
