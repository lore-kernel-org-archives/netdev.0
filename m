From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] sit: use kfree_skb to replace dev_kfree_skb
Date: Mon, 25 Nov 2013 06:58:24 -0800
Message-ID: <1385391504.10637.134.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1385371284-15105-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:54104 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754562Ab3KYO6Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Nov 2013 09:58:25 -0500
Received: by mail-pb0-f41.google.com with SMTP id jt11so5913111pbb.0
        for <netdev@vger.kernel.org>; Mon, 25 Nov 2013 06:58:25 -0800 (PST)
In-Reply-To: <1385371284-15105-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-11-25 at 17:21 +0800, Gao feng wrote:
> In failure case, we should use kfree_skb not
> dev_kfree_skb to free skbuff, dev_kfree_skb
> is defined as consume_skb.
> 
> Trace takes advantage of this point.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> ---
>  net/ipv6/sit.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)

Seems fine to me, thanks !

Acked-by: Eric Dumazet <edumazet@google.com>
