From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 2/2] tcp: remove SKBTX_ACK_TSTAMP since it
 is redundant
Date: Wed, 27 Apr 2016 21:37:35 -0700
Message-ID: <1461818255.5535.89.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1461814741-848-1-git-send-email-soheil.kdev@gmail.com>
	 <1461814741-848-3-git-send-email-soheil.kdev@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, kafai@fb.com,
	willemb@google.com, edumazet@google.com, ycheng@google.com,
	ncardwell@google.com, Soheil Hassas Yeganeh <soheil@google.com>
To: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f49.google.com ([209.85.192.49]:35464 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750792AbcD1Ehj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 00:37:39 -0400
Received: by mail-qg0-f49.google.com with SMTP id f74so25697287qge.2
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 21:37:38 -0700 (PDT)
In-Reply-To: <1461814741-848-3-git-send-email-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-04-27 at 23:39 -0400, Soheil Hassas Yeganeh wrote:
> From: Soheil Hassas Yeganeh <soheil@google.com>
> 
> The SKBTX_ACK_TSTAMP flag is set in skb_shinfo->tx_flags when
> the timestamp of the TCP acknowledgement should be reported on
> error queue. Since accessing skb_shinfo is likely to incur a
> cache-line miss at the time of receiving the ack, the
> txstamp_ack bit was added in tcp_skb_cb, which is set iff
> the SKBTX_ACK_TSTAMP flag is set for an skb. This makes
> SKBTX_ACK_TSTAMP flag redundant.
> 
> Remove the SKBTX_ACK_TSTAMP and instead use the txstamp_ack bit
> everywhere.
> 
> Note that this frees one bit in shinfo->tx_flags.
> 
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
> Acked-by: Martin KaFai Lau <kafai@fb.com>
> Suggested-by: Willem de Bruijn <willemb@google.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
