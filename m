From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] net: Rename sock_recv_ts_and_drops() to
 sock_cmsg_recv()
Date: Mon, 09 Feb 2015 18:55:35 -0800 (PST)
Message-ID: <20150209.185535.1300672977479433508.davem@davemloft.net>
References: <1423505723-2281-1-git-send-email-eyal.birger@gmail.com>
	<1423505723-2281-2-git-send-email-eyal.birger@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org
To: eyal.birger@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53305 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750808AbbBJCzg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 21:55:36 -0500
In-Reply-To: <1423505723-2281-2-git-send-email-eyal.birger@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eyal Birger <eyal.birger@gmail.com>
Date: Mon,  9 Feb 2015 20:15:21 +0200

> -void __sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
> +void __sock_cmsg_recv(struct msghdr *msg, struct sock *sk,
>  			      struct sk_buff *skb);

If you change the column where the openning parenthesis of a function
declaration appears, you have to reindent the subsequent lines,
if any, so that the arguments still begin at the first column after
that openning parenthesis.

>  
> -static inline void sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
> +static inline void sock_cmsg_recv(struct msghdr *msg, struct sock *sk,
>  					  struct sk_buff *skb)

Likewise.

Please audit your entire patch series for this problem before resubmitting.

Also, this new feature is too late for this merge window, so there is
no rush for resubmitting this.
