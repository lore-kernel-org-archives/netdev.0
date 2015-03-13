From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] inet_diag: fix possible overflow in
 inet_diag_dump_one_icsk()
Date: Fri, 13 Mar 2015 09:47:22 -0700
Message-ID: <1426265242.11398.189.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1426262994.11398.188.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:32877 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752134AbbCMQrc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 12:47:32 -0400
Received: by iecvj10 with SMTP id vj10so110985867iec.0
        for <netdev@vger.kernel.org>; Fri, 13 Mar 2015 09:47:31 -0700 (PDT)
In-Reply-To: <1426262994.11398.188.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-03-13 at 09:09 -0700, Eric Dumazet wrote:


> 
> diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
> index 81751f12645f..3ad64c8e4079 100644
> --- a/net/ipv4/inet_diag.c
> +++ b/net/ipv4/inet_diag.c
> @@ -71,6 +71,20 @@ static inline void inet_diag_unlock_handler(
>  	mutex_unlock(&inet_diag_table_mutex);
>  }
>  
> +size_t inet_sk_attr_size(void)

Arg, I forgot static here, will send a v2
