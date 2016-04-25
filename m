From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 net-next 2/3] tcp: Handle eor bit when coalescing skb
Date: Mon, 25 Apr 2016 16:03:06 -0700
Message-ID: <1461625386.5535.26.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1461620690-1081063-1-git-send-email-kafai@fb.com>
	 <1461620690-1081063-3-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Soheil Hassas Yeganeh <soheil@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:35003 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751860AbcDYXDJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 19:03:09 -0400
Received: by mail-pf0-f177.google.com with SMTP id n1so74723937pfn.2
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 16:03:08 -0700 (PDT)
In-Reply-To: <1461620690-1081063-3-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-04-25 at 14:44 -0700, Martin KaFai Lau wrote:
> This patch:
> 1. Prevent next_skb from coalescing to the prev_skb if
>    TCP_SKB_CB(prev_skb)->eor is set
> 2. Update the TCP_SKB_CB(prev_skb)->eor if coalescing is
>    allowed

Acked-by: Eric Dumazet <edumazet@google.com>
