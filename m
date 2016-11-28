From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next v2 6/6] tcp: SOF_TIMESTAMPING_OPT_STATS option
 for SO_TIMESTAMPING
Date: Mon, 28 Nov 2016 12:26:32 -0500
Message-ID: <CADVnQymnNWLN7LRXN3zUHVwwz=9JsYB7LUFMQUm-dw8uOauLRA@mail.gmail.com>
References: <1480316838-154141-1-git-send-email-ycheng@google.com> <1480316838-154141-7-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        francisyyan@gmail.com, Netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:36122 "EHLO
        mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750832AbcK1R1E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 12:27:04 -0500
Received: by mail-oi0-f53.google.com with SMTP id v84so158509257oie.3
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 09:27:03 -0800 (PST)
In-Reply-To: <1480316838-154141-7-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 28, 2016 at 2:07 AM, Yuchung Cheng <ycheng@google.com> wrote:
> From: Francis Yan <francisyyan@gmail.com>
>
> This patch exports the sender chronograph stats via the socket
> SO_TIMESTAMPING channel. Currently we can instrument how long a
> particular application unit of data was queued in TCP by tracking
> SOF_TIMESTAMPING_TX_SOFTWARE and SOF_TIMESTAMPING_TX_SCHED. Having
> these sender chronograph stats exported simultaneously along with
> these timestamps allow further breaking down the various sender
> limitation.  For example, a video server can tell if a particular
> chunk of video on a connection takes a long time to deliver because
> TCP was experiencing small receive window. It is not possible to
> tell before this patch without packet traces.
>
> To prepare these stats, the user needs to set
> SOF_TIMESTAMPING_OPT_STATS and SOF_TIMESTAMPING_OPT_TSONLY flags
> while requesting other SOF_TIMESTAMPING TX timestamps. When the
> timestamps are available in the error queue, the stats are returned
> in a separate control message of type SCM_TIMESTAMPING_OPT_STATS,
> in a list of TLVs (struct nlattr) of types: TCP_NLA_BUSY_TIME,
> TCP_NLA_RWND_LIMITED, TCP_NLA_SNDBUF_LIMITED. Unit is microsecond.
>
> Signed-off-by: Francis Yan <francisyyan@gmail.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
> ---

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
