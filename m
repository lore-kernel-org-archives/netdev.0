From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] neigh: increase queue_len_bytes to match
 wmem_default
Date: Tue, 29 Aug 2017 16:15:28 -0700
Message-ID: <1504048528.11498.109.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1503712322.11498.12.camel@edumazet-glaptop3.roam.corp.google.com>
         <354e6c3a-1771-e8a7-24dd-1b70266563af@gmail.com>
         <1503718844.11498.19.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170825.211905.920493778125075310.davem@davemloft.net>
         <1503751671.11498.25.camel@edumazet-glaptop3.roam.corp.google.com>
         <deb227c9-728a-bd98-f282-1478d71353a8@gmail.com>
         <353aa37f-c62b-f5af-8c89-f67af6509497@gmail.com>
         <1504029689.11498.79.camel@edumazet-glaptop3.roam.corp.google.com>
         <1504044961.11498.100.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:34860 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751297AbdH2XV5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 19:21:57 -0400
Received: by mail-pg0-f49.google.com with SMTP id 63so14883108pgc.2
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 16:21:57 -0700 (PDT)
In-Reply-To: <1504044961.11498.100.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-08-29 at 15:16 -0700, Eric Dumazet wrote:
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index
> 568ccfd6dd371d88136ffabe5cfcc36f099786b6..7616cd76f6f6a62f395da897baef2c66c0098193 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -6086,9 +6086,9 @@ int tcp_conn_request(struct request_sock_ops
> *rsk_ops,
>         struct tcp_sock *tp = tcp_sk(sk);
>         struct net *net = sock_net(sk);
>         struct sock *fastopen_sk = NULL;
> -       struct dst_entry *dst = NULL;
>         struct request_sock *req;
>         bool want_cookie = false;
> +       struct dst_entry *dst;
>         struct flowi fl;
>  
>         /* TW buckets are converted to open req

This part was meant to belong to a separate patch :/

No big deal, this was also one of your suggestion David.
