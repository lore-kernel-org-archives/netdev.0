From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 net-next 1/3] tcp: Make use of MSG_EOR in tcp_sendmsg
Date: Mon, 25 Apr 2016 16:02:13 -0700
Message-ID: <1461625333.5535.25.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1461620690-1081063-1-git-send-email-kafai@fb.com>
	 <1461620690-1081063-2-git-send-email-kafai@fb.com>
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
Received: from mail-pf0-f176.google.com ([209.85.192.176]:36746 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750749AbcDYXCQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 19:02:16 -0400
Received: by mail-pf0-f176.google.com with SMTP id c189so27607462pfb.3
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 16:02:15 -0700 (PDT)
In-Reply-To: <1461620690-1081063-2-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-04-25 at 14:44 -0700, Martin KaFai Lau wrote:
> This patch adds an eor bit to the TCP_SKB_CB.  When MSG_EOR
> is passed to tcp_sendmsg, the eor bit will be set at the skb
> containing the last byte of the userland's msg.  The eor bit
> will prevent data from appending to that skb in the future.

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks !
