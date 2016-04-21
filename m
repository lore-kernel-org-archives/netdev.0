From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next 1/2] tcp: Carry txstamp_ack in tcp_fragment_tstamp
Date: Thu, 21 Apr 2016 15:45:56 -0400
Message-ID: <CAF=yD-Jd-gvRM75LjSTPr3z8kWcGd-jC46Smc2RiZHt6oZE4tg@mail.gmail.com>
References: <1461131448-1460418-1-git-send-email-kafai@fb.com> <1461131448-1460418-2-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Soheil Hassas Yeganeh <soheil@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:36135 "EHLO
	mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753457AbcDUTqh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 15:46:37 -0400
Received: by mail-lf0-f67.google.com with SMTP id j10so8446513lfg.3
        for <netdev@vger.kernel.org>; Thu, 21 Apr 2016 12:46:36 -0700 (PDT)
In-Reply-To: <1461131448-1460418-2-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 20, 2016 at 1:50 AM, Martin KaFai Lau <kafai@fb.com> wrote:
> When a tcp skb is sliced into two smaller skbs (e.g. in
> tcp_fragment() and tso_fragment()),  it does not carry
> the txstamp_ack bit to the newly created skb if it is needed.
> The end result is a timestamping event (SCM_TSTAMP_ACK) will
> be missing from the sk->sk_error_queue.
>
> This patch carries this bit to the new skb2
> in tcp_fragment_tstamp().

> Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Soheil Hassas Yeganeh <soheil@google.com>
> Cc: Willem de Bruijn <willemb@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Acked-by: Soheil Hassas Yeganeh <soheil@google.com>

Acked-by: Willem de Bruijn <willemb@google.com>
