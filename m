From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next v2 2/6] tcp: instrument how long TCP is busy sending
Date: Mon, 28 Nov 2016 12:24:30 -0500
Message-ID: <CADVnQymOPai5GqELLEVSr+myj6Zg=6HTnbZxwy1O74OciWgTPQ@mail.gmail.com>
References: <1480316838-154141-1-git-send-email-ycheng@google.com> <1480316838-154141-3-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        francisyyan@gmail.com, Netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:36522 "EHLO
        mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750799AbcK1RZB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 12:25:01 -0500
Received: by mail-oi0-f45.google.com with SMTP id v84so158426350oie.3
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 09:25:00 -0800 (PST)
In-Reply-To: <1480316838-154141-3-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 28, 2016 at 2:07 AM, Yuchung Cheng <ycheng@google.com> wrote:
> From: Francis Yan <francisyyan@gmail.com>
>
> This patch measures TCP busy time, which is defined as the period
> of time when sender has data (or FIN) to send. The time starts when
> data is buffered and stops when the write queue is flushed by ACKs
> or error events.
>
> Note the busy time does not include SYN time, unless data is
> included in SYN (i.e. Fast Open). It does include FIN time even
> if the FIN carries no payload. Excluding pure FIN is possible but
> would incur one additional test in the fast path, which may not
> be worth it.
>
> Signed-off-by: Francis Yan <francisyyan@gmail.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
> ---

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
