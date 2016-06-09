From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: diag: add missing declarations
Date: Thu, 09 Jun 2016 07:10:46 -0700
Message-ID: <1465481446.7945.40.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1465471048-13493-1-git-send-email-ben.dooks@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@lists.codethink.co.uk,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ben Dooks <ben.dooks@codethink.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33516 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750810AbcFIOKu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 10:10:50 -0400
In-Reply-To: <1465471048-13493-1-git-send-email-ben.dooks@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-06-09 at 12:17 +0100, Ben Dooks wrote:
> The functions inet_diag_msg_common_fill and inet_diag_msg_attrs_fill
> seem to have been missed from the include/linux/inet_diag.h header
> file. Add them to fix the following warnings:
> 
> net/ipv4/inet_diag.c:69:6: warning: symbol 'inet_diag_msg_common_fill' was not declared. Should it be static?
> net/ipv4/inet_diag.c:108:5: warning: symbol 'inet_diag_msg_attrs_fill' was not declared. Should it be static?
> 
> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
> ---
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> ---
>  include/linux/inet_diag.h | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
> index 7c27fa1..feb04ea 100644
> --- a/include/linux/inet_diag.h
> +++ b/include/linux/inet_diag.h
> @@ -52,6 +52,12 @@ struct sock *inet_diag_find_one_icsk(struct net *net,
>  
>  int inet_diag_bc_sk(const struct nlattr *_bc, struct sock *sk);
>  
> +void inet_diag_msg_common_fill(struct inet_diag_msg *r, struct sock *sk);
> +
> +int inet_diag_msg_attrs_fill(struct sock *sk, struct sk_buff *skb,
> +			     struct inet_diag_msg *r, int ext,
> +			     struct user_namespace *user_ns);
> +
>  extern int  inet_diag_register(const struct inet_diag_handler *handler);
>  extern void inet_diag_unregister(const struct inet_diag_handler *handler);
>  #endif /* _INET_DIAG_H_ */

Please send a v2, deleting them from net/sctp/sctp_diag.c

Thanks.
