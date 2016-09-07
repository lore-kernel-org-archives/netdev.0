From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] tcp: measure rwnd-limited time
Date: Wed, 07 Sep 2016 07:19:16 -0700
Message-ID: <1473257956.10725.26.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1473211961-107223-1-git-send-email-francisyyan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, edumazet@google.com,
        soheil@google.com, ncardwell@google.com,
        Yuchung Cheng <ycheng@google.com>
To: "Francis Y. Yan" <francisyyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:34575 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756459AbcIGOTT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 10:19:19 -0400
Received: by mail-pf0-f171.google.com with SMTP id p64so7229419pfb.1
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 07:19:18 -0700 (PDT)
In-Reply-To: <1473211961-107223-1-git-send-email-francisyyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-09-06 at 18:32 -0700, Francis Y. Yan wrote:
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
> ---

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks Francis !
