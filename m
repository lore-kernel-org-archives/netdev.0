From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 8/8] tcp: tsq: move tsq_flags close to
 sk_wmem_alloc
Date: Sat, 03 Dec 2016 19:16:26 -0500 (EST)
Message-ID: <20161203.191626.976921736888291388.davem@davemloft.net>
References: <1480792497-16607-1-git-send-email-edumazet@google.com>
        <1480792497-16607-9-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com, eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39438 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751638AbcLDARI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 19:17:08 -0500
In-Reply-To: <1480792497-16607-9-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Sat,  3 Dec 2016 11:14:57 -0800

> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> index d8be083ab0b0..fc5848dad7a4 100644
> --- a/include/linux/tcp.h
> +++ b/include/linux/tcp.h
> @@ -186,7 +186,6 @@ struct tcp_sock {
>  	u32	tsoffset;	/* timestamp offset */
>  
>  	struct list_head tsq_node; /* anchor in tsq_tasklet.head list */
> -	unsigned long	tsq_flags;
>  
>  	/* Data for direct copy to user */
>  	struct {

Hmmm, did you forget to "git add include/net/sock.h" before making
this commit?
