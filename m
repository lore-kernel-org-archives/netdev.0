From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] tcp: ecn: dont delay ACKS after CE
Date: Mon, 6 Aug 2012 17:07:08 -0400
Message-ID: <CADVnQyk25R4qpXq7Mho=uHwCswALPdOR=nP=AjQy7qJyT+HFuA@mail.gmail.com>
References: <1344287083.26674.83.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:42466 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754121Ab2HFVHJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2012 17:07:09 -0400
Received: by yenl2 with SMTP id l2so3011112yen.19
        for <netdev@vger.kernel.org>; Mon, 06 Aug 2012 14:07:09 -0700 (PDT)
In-Reply-To: <1344287083.26674.83.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 6, 2012 at 5:04 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> While playing with CoDel and ECN marking, I discovered a
> non optimal behavior of receiver of CE (Congestion Encountered)
> segments.
>
> In pathological cases, sender has reduced its cwnd to low values,
> and receiver delays its ACK (by 40 ms).
>
> While RFC 3168 6.1.3 (The TCP Receiver) doesn't explicitly recommend
> to send immediate ACKS, we believe its better to not delay ACKS, because
> a CE segment should give same signal than a dropped segment, and its
> quite important to reduce RTT to give ECE/CWR signals as fast as
> possible.
>
> Note we already call tcp_enter_quickack_mode() from TCP_ECN_check_ce()
> if we receive a retransmit, for the same reason.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
