From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC V3] net: don't wait for order-3 page allocation
Date: Thu, 11 Jun 2015 17:02:22 -0700
Message-ID: <1434067342.27504.73.camel@edumazet-glaptop2.roam.corp.google.com>
References: <0099265406c32b9b9057de100404a4148d602cdd.1434066549.git.shli@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, Kernel-team@fb.com,
	clm@fb.com, linux-mm@kvack.org, dbavatar@gmail.com,
	Eric Dumazet <edumazet@google.com>
To: Shaohua Li <shli@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:36819 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752191AbbFLACY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 20:02:24 -0400
Received: by iebps5 with SMTP id ps5so14348297ieb.3
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2015 17:02:23 -0700 (PDT)
In-Reply-To: <0099265406c32b9b9057de100404a4148d602cdd.1434066549.git.shli@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-06-11 at 16:50 -0700, Shaohua Li wrote:
> We saw excessive direct memory compaction triggered by skb_page_frag_refill.
> This causes performance issues and add latency. Commit 5640f7685831e0
> introduces the order-3 allocation. According to the changelog, the order-3
> allocation isn't a must-have but to improve performance. But direct memory
> compaction has high overhead. The benefit of order-3 allocation can't
> compensate the overhead of direct memory compaction.

> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Chris Mason <clm@fb.com>
> Cc: Debabrata Banerjee <dbavatar@gmail.com>
> Signed-off-by: Shaohua Li <shli@fb.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks.
