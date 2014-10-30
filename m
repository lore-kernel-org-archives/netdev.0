From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: Correction to RFC number in comment
Date: Thu, 30 Oct 2014 10:19:09 -0700
Message-ID: <1414689549.9028.1.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141030164808.GH650@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:36113 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757327AbaJ3RTM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 13:19:12 -0400
Received: by mail-pd0-f172.google.com with SMTP id r10so5529909pdi.17
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2014 10:19:11 -0700 (PDT)
In-Reply-To: <20141030164808.GH650@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-10-30 at 12:48 -0400, Sowmini Varadhan wrote:
> Challenge ACK is described in RFC 5961, fix typo.
> 
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> ---
>  net/ipv4/tcp_input.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index a12b455..d285962 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -5028,7 +5028,7 @@ static bool tcp_validate_incoming(struct sock *sk, struct sk_buff *skb,
>  	/* step 3: check security and precedence [ignored] */
>  
>  	/* step 4: Check for a SYN
> -	 * RFC 5691 4.2 : Send a challenge ack
> +	 * RFC 5961 4.2 : Send a challenge ack
>  	 */
>  	if (th->syn) {
>  syn_challenge:

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks !
