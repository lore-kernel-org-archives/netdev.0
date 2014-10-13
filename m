From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: dst_entry leak in ip_append_data()
Date: Mon, 13 Oct 2014 12:03:52 -0400 (EDT)
Message-ID: <20141013.120352.215182678857080235.davem@davemloft.net>
References: <543BA6BE.3040509@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, eric.dumazet@gmail.com
To: vvs@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60958 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753952AbaJMQD6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2014 12:03:58 -0400
In-Reply-To: <543BA6BE.3040509@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasily Averin <vvs@parallels.com>
Date: Mon, 13 Oct 2014 14:17:34 +0400

> @@ -1152,9 +1161,14 @@ int ip_append_data(struct sock *sk, struct flowi4 *fl4,
>  		transhdrlen = 0;
>  	}
>  
> -	return __ip_append_data(sk, fl4, &sk->sk_write_queue, &inet->cork.base,
> +	err = __ip_append_data(sk, fl4, &sk->sk_write_queue, &inet->cork.base,
>  				sk_page_frag(sk), getfrag,
>  				from, length, transhdrlen, flags);

If you are changing the column of the openning parenthesis of the function
call, you must adjust the indentation of the arguments on the subsequent
lines so that they start exactly at the first column after that openning
parenthesis.

Thanks.
