From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next v2 4/6] tcp: instrument how long TCP is limited
 by insufficient send buffer
Date: Mon, 28 Nov 2016 12:25:36 -0500
Message-ID: <CADVnQy=VhKubFx4yLwYAbYUieB57rB4sr27jhrKtnjgwxqzMig@mail.gmail.com>
References: <1480316838-154141-1-git-send-email-ycheng@google.com> <1480316838-154141-5-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        francisyyan@gmail.com, Netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:36404 "EHLO
        mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751317AbcK1R0J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 12:26:09 -0500
Received: by mail-oi0-f52.google.com with SMTP id v84so158471657oie.3
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 09:26:07 -0800 (PST)
In-Reply-To: <1480316838-154141-5-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 28, 2016 at 2:07 AM, Yuchung Cheng <ycheng@google.com> wrote:
> From: Francis Yan <francisyyan@gmail.com>
>
> This patch measures the amount of time when TCP runs out of new data
> to send to the network due to insufficient send buffer, while TCP
> is still busy delivering (i.e. write queue is not empty). The goal
> is to indicate either the send buffer autotuning or user SO_SNDBUF
> setting has resulted network under-utilization.
>
> The measurement starts conservatively by checking various conditions
> to minimize false claims (i.e. under-estimation is more likely).
> The measurement stops when the SOCK_NOSPACE flag is cleared. But it
> does not account the time elapsed till the next application write.
> Also the measurement only starts if the sender is still busy sending
> data, s.t. the limit accounted is part of the total busy time.
>
> Signed-off-by: Francis Yan <francisyyan@gmail.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
> ---

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
