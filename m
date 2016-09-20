From: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Subject: Re: [PATCH v4 net-next 01/16] tcp: cdg: rename struct minmax in
 tcp_cdg.c to avoid a naming conflict
Date: Tue, 20 Sep 2016 18:40:01 +0200
Message-ID: <CA++eYdvqpUkJWi6O_Kr4YG+WPMPJYUzBOyFKogRQSKQ5UpOMWw@mail.gmail.com>
References: <1474342763-16715-1-git-send-email-ncardwell@google.com> <1474342763-16715-2-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35517 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755170AbcITQkD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 12:40:03 -0400
Received: by mail-wm0-f67.google.com with SMTP id 133so4337953wmq.2
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 09:40:03 -0700 (PDT)
In-Reply-To: <1474342763-16715-2-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 20, 2016 at 5:39 AM, Neal Cardwell <ncardwell@google.com> wrote:
>
> From: Soheil Hassas Yeganeh <soheil@google.com>
>
> The upcoming change "lib/win_minmax: windowed min or max estimator"
> introduces a struct called minmax, which is then included in
> include/linux/tcp.h in the upcoming change "tcp: use windowed min
> filter library for TCP min_rtt estimation". This would create a
> compilation error for tcp_cdg.c, which defines its own minmax
> struct. To avoid this naming conflict (and potentially others in the
> future), this commit renames the version used in tcp_cdg.c to
> cdg_minmax.
>
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>

Acked-by: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
