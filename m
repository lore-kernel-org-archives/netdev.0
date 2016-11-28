From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next v2 5/6] tcp: export sender limits chronographs to TCP_INFO
Date: Mon, 28 Nov 2016 12:26:01 -0500
Message-ID: <CADVnQy=LNJzLwzTCnD6=QYVjvv17PWfXUtosi4-vL0yAEJ7fqQ@mail.gmail.com>
References: <1480316838-154141-1-git-send-email-ycheng@google.com> <1480316838-154141-6-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        francisyyan@gmail.com, Netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:35174 "EHLO
        mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750832AbcK1R0c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 12:26:32 -0500
Received: by mail-oi0-f50.google.com with SMTP id b126so158600641oia.2
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 09:26:31 -0800 (PST)
In-Reply-To: <1480316838-154141-6-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 28, 2016 at 2:07 AM, Yuchung Cheng <ycheng@google.com> wrote:
> From: Francis Yan <francisyyan@gmail.com>
>
> This patch exports all the sender chronograph measurements collected
> in the previous patches to TCP_INFO interface. Note that busy time
> exported includes all the other sending limits (rwnd-limited,
> sndbuf-limited). Internally the time unit is jiffy but externally
> the measurements are in microseconds for future extensions.
>
> Signed-off-by: Francis Yan <francisyyan@gmail.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
> ---

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
