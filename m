From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net] tcp: avoid setting cwnd to invalid ssthresh after
 cwnd reduction states
Date: Wed, 2 Aug 2017 10:58:54 -0700
Message-ID: <CAK6E8=ft9MQq5BJ_GwguHLoAXMyBWzJDBi4JMthY9PWEGxd3rA@mail.gmail.com>
References: <20170801202232.162176-1-ycheng@google.com> <20170802.105136.1599120748083773522.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev <netdev@vger.kernel.org>,
        Neal Cardwell <ncardwell@google.com>,
        Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f181.google.com ([209.85.128.181]:37345 "EHLO
        mail-wr0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753089AbdHBR7h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 13:59:37 -0400
Received: by mail-wr0-f181.google.com with SMTP id 33so21584405wrz.4
        for <netdev@vger.kernel.org>; Wed, 02 Aug 2017 10:59:36 -0700 (PDT)
In-Reply-To: <20170802.105136.1599120748083773522.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 2, 2017 at 10:51 AM, David Miller <davem@davemloft.net> wrote:
>
> From: Yuchung Cheng <ycheng@google.com>
> Date: Tue,  1 Aug 2017 13:22:32 -0700
>
> > If the sender switches the congestion control during ECN-triggered
> > cwnd-reduction state (CA_CWR), upon exiting recovery cwnd is set to
> > the ssthresh value calculated by the previous congestion control. If
> > the previous congestion control is BBR that always keep ssthresh
> > to TCP_INIFINITE_SSTHRESH, cwnd ends up being infinite. The safe
> > step is to avoid assigning invalid ssthresh value when recovery ends.
> >
> > Signed-off-by: Yuchung Cheng <ycheng@google.com>
> > Signed-off-by: Neal Cardwell <ncardwell@google.com>
>
> Applied, thanks.
>
> Is this a -stable candidate?

Yes it is. Thanks!
