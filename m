From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next v2 3/6] tcp: instrument how long TCP is limited
 by receive window
Date: Mon, 28 Nov 2016 12:25:05 -0500
Message-ID: <CADVnQy=sp_3jo5abxeWDZFnF2i_hNsMhQnbX7Ai0W8CBtOUd5A@mail.gmail.com>
References: <1480316838-154141-1-git-send-email-ycheng@google.com> <1480316838-154141-4-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        francisyyan@gmail.com, Netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:33374 "EHLO
        mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750799AbcK1RZg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 12:25:36 -0500
Received: by mail-oi0-f45.google.com with SMTP id w63so158989395oiw.0
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 09:25:36 -0800 (PST)
In-Reply-To: <1480316838-154141-4-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 28, 2016 at 2:07 AM, Yuchung Cheng <ycheng@google.com> wrote:
> From: Francis Yan <francisyyan@gmail.com>
>
> This patch measures the total time when the TCP stops sending because
> the receiver's advertised window is not large enough. Note that
> once the limit is lifted we are likely in the busy status if we
> have data pending.
>
> Signed-off-by: Francis Yan <francisyyan@gmail.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
> ---

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
