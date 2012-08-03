From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: remove parentheses in return statement
Date: Fri, 03 Aug 2012 11:19:44 +0200
Message-ID: <1343985584.9299.873.camel@edumazet-glaptop>
References: <1343979790-17408-1-git-send-email-sakiwit@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jean Sacren <sakiwit@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:47204 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752675Ab2HCJTt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2012 05:19:49 -0400
Received: by bkwj10 with SMTP id j10so157159bkw.19
        for <netdev@vger.kernel.org>; Fri, 03 Aug 2012 02:19:47 -0700 (PDT)
In-Reply-To: <1343979790-17408-1-git-send-email-sakiwit@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-08-03 at 01:43 -0600, Jean Sacren wrote:

> @@ -106,8 +106,8 @@ static inline unsigned int inet_addr_hash(struct net *net, __be32 addr)
>  {
>  	u32 val = (__force u32) addr ^ hash_ptr(net, 8);
>  
> -	return ((val ^ (val >> 8) ^ (val >> 16) ^ (val >> 24)) &
> -		(IN4_ADDR_HSIZE - 1));
> +	return (val ^ (val >> 8) ^ (val >> 16) ^ (val >> 24)) &
> +	       (IN4_ADDR_HSIZE - 1);
>  }

BTW This should use a faster implementation, I'll send a patch when
net-next is opened.
