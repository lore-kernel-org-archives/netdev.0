From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH 4/5] tcp: improve fastopen icmp handling
Date: Mon, 12 May 2014 15:30:58 -0400
Message-ID: <CADVnQynDZFTmTZk_2BhS=y5bf+0nWYsPtUUqyh=3ry6dN2ko3A@mail.gmail.com>
References: <1399864933-28287-1-git-send-email-ycheng@google.com>
	<1399864933-28287-5-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, longinus00@gmail.com,
	Jerry Chu <hkchu@google.com>, Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:61908 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751828AbaELTa7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 15:30:59 -0400
Received: by mail-wi0-f182.google.com with SMTP id r20so5102506wiv.3
        for <netdev@vger.kernel.org>; Mon, 12 May 2014 12:30:58 -0700 (PDT)
In-Reply-To: <1399864933-28287-5-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 11, 2014 at 11:22 PM, Yuchung Cheng <ycheng@google.com> wrote:
> If a fast open socket is already accepted by the user, it should
> be treated like a connected socket to record the ICMP error in
> sk_softerr, so the user can fetch it. Do that in both tcp_v4_err
> and tcp_v6_err.
>
> Also refactor the sequence window check to improve readability
> (e.g., there were two local variables named 'req').
>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Daniel Lee <longinus00@gmail.com>
> Signed-off-by: Jerry Chu <hkchu@google.com>
> ---
>  net/ipv4/tcp_ipv4.c | 35 ++++++++++++++---------------------
>  net/ipv6/tcp_ipv6.c | 22 +++++++++++++++++-----
>  2 files changed, 31 insertions(+), 26 deletions(-)

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
