From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next 05/15] bpf: Support for setting initial
 receive window
Date: Tue, 13 Jun 2017 17:14:18 -0400 (EDT)
Message-ID: <20170613.171418.2256613910701215130.davem@davemloft.net>
References: <20170613180004.3008403-1-brakmo@fb.com>
        <20170613180004.3008403-6-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com, bmatheny@fb.com,
        ast@fb.com, daniel@iogearbox.net, dsa@cumulusnetworks.com
To: brakmo@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51184 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752326AbdFMVOT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 17:14:19 -0400
In-Reply-To: <20170613180004.3008403-6-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lawrence Brakmo <brakmo@fb.com>
Date: Tue, 13 Jun 2017 10:59:54 -0700

> diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
> index d0642df..a0032ea 100644
> --- a/net/ipv4/tcp_minisocks.c
> +++ b/net/ipv4/tcp_minisocks.c
> @@ -352,6 +352,7 @@ void tcp_openreq_init_rwin(struct request_sock *req,
>  	u32 window_clamp;
>  	__u8 rcv_wscale;
>  	int mss;
> +	u32 rcv_wnd;

Please order local variables from longest to shortest line.

 ...
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 503e478..972a985 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -3267,6 +3267,7 @@ static void tcp_connect_init(struct sock *sk)
>  	const struct dst_entry *dst = __sk_dst_get(sk);
>  	struct tcp_sock *tp = tcp_sk(sk);
>  	__u8 rcv_wscale;
> +	u32 rcv_wnd;

Likewise.
