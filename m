From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 net-next 3/3] tcp: Handle eor bit when fragmenting a
 skb
Date: Mon, 25 Apr 2016 16:04:58 -0700
Message-ID: <1461625498.5535.27.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1461620690-1081063-1-git-send-email-kafai@fb.com>
	 <1461620690-1081063-4-git-send-email-kafai@fb.com>
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
Received: from mail-pf0-f175.google.com ([209.85.192.175]:33184 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751704AbcDYXFA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 19:05:00 -0400
Received: by mail-pf0-f175.google.com with SMTP id 206so23278105pfu.0
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 16:04:59 -0700 (PDT)
In-Reply-To: <1461620690-1081063-4-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-04-25 at 14:44 -0700, Martin KaFai Lau wrote:
> When fragmenting a skb, the next_skb should carry
> the eor from prev_skb.  The eor of prev_skb should
> also be reset.


Acked-by: Eric Dumazet <edumazet@google.com>
