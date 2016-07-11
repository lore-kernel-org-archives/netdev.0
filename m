From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH net] tcp_timer.c: Add kernel-doc function descriptions
Date: Mon, 11 Jul 2016 20:59:39 +0100
Message-ID: <61a5fef9-a68d-9569-056c-b45cf831c53f@solarflare.com>
References: <1468011506-358-1-git-send-email-richard@weltraumpflege.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>
To: Richard Sailer <richard@weltraumpflege.org>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:23119 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751051AbcGKT7w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 15:59:52 -0400
In-Reply-To: <1468011506-358-1-git-send-email-richard@weltraumpflege.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/07/16 21:58, Richard Sailer wrote:
> This adds kernel-doc style descriptions for 6 functions and
> fixes 1 typo.
>
> Signed-off-by: Richard Sailer <richard@weltraumpflege.org>
> ---
>  net/ipv4/tcp_timer.c | 66 +++++++++++++++++++++++++++++++++++++++++++++-------
>  1 file changed, 57 insertions(+), 9 deletions(-)
>
> diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
> index debdd8b..bdccd67 100644
> --- a/net/ipv4/tcp_timer.c
> +++ b/net/ipv4/tcp_timer.c
> @@ -350,10 +389,18 @@ static void tcp_fastopen_synack_timer(struct sock *sk)
>  			  TCP_TIMEOUT_INIT << req->num_timeout, TCP_RTO_MAX);
>  }
>  
> -/*
> - *	The TCP retransmit timer.
> - */
>  
> +/**
> + * tcp_retransmit_timer() - The TCP retransmit timout handler.
"timeout"
-Ed
