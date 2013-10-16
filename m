From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: remove redundant code in
 __tcp_retransmit_skb()
Date: Wed, 16 Oct 2013 09:44:03 -0700
Message-ID: <1381941843.2045.132.camel@edumazet-glaptop.roam.corp.google.com>
References: <1381941411-30645-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:50053 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760808Ab3JPQoF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 12:44:05 -0400
Received: by mail-pa0-f52.google.com with SMTP id kl14so1315921pab.25
        for <netdev@vger.kernel.org>; Wed, 16 Oct 2013 09:44:04 -0700 (PDT)
In-Reply-To: <1381941411-30645-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-16 at 12:36 -0400, Neal Cardwell wrote:
> Remove the specialized code in __tcp_retransmit_skb() that tries to trim
> any ACKed payload preceding a FIN before we retransmit (this was added
> in 1999 in v2.2.3pre3). This trimming code was made unreachable by the
> more general code added above it that uses tcp_trim_head() to trim any
> ACKed payload, with or without a FIN (this was added in "[NET]: Add
> segmentation offload support to TCP." in 2002 circa v2.5.33).
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> ---
>  net/ipv4/tcp_output.c | 15 ---------------
>  1 file changed, 15 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
