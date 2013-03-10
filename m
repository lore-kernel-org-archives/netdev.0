From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] Remove unused tw_cookie_values from
 tcp_timewait_sock
Date: Sun, 10 Mar 2013 17:06:10 +0100
Message-ID: <1362931570.4051.34.camel@edumazet-glaptop>
References: <1362928719-13532-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	william.allen.simpson@gmail.com
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f53.google.com ([74.125.83.53]:37464 "EHLO
	mail-ee0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751110Ab3CJQNG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Mar 2013 12:13:06 -0400
Received: by mail-ee0-f53.google.com with SMTP id e53so1768474eek.12
        for <netdev@vger.kernel.org>; Sun, 10 Mar 2013 09:13:04 -0700 (PDT)
In-Reply-To: <1362928719-13532-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-03-10 at 16:18 +0100, Christoph Paasch wrote:
> tw_cookie_values is never used in the TCP-stack.
> 
> It was added by 435cf559f (TCPCT part 1d: define TCP cookie option,
> extend existing struct's), but already at that time it was not used at
> all, nor mentioned in the commit-message.
> 
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> ---
>  include/linux/tcp.h | 4 ----
>  1 file changed, 4 deletions(-)
> 
> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> index f28408c..515c374 100644
> --- a/include/linux/tcp.h
> +++ b/include/linux/tcp.h
> @@ -361,10 +361,6 @@ struct tcp_timewait_sock {
>  #ifdef CONFIG_TCP_MD5SIG
>  	struct tcp_md5sig_key	  *tw_md5_key;
>  #endif
> -	/* Few sockets in timewait have cookies; in that case, then this
> -	 * object holds a reference to them (tw_cookie_values->kref).
> -	 */
> -	struct tcp_cookie_values  *tw_cookie_values;
>  };
>  
>  static inline struct tcp_timewait_sock *tcp_twsk(const struct sock *sk)

Acked-by: Eric Dumazet <edumazet@google.com>

Actually, I am not sure TCPCT is really used...
