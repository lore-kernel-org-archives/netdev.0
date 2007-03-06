From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH] fix compat_sock_common_getsockopt typo
Date: Tue, 6 Mar 2007 10:06:00 -0500 (EST)
Message-ID: <Line.LNX.4.64.0703061005420.22674@d.namei>
References: <1173137211.15891.27.camel@johannes.berg>
 <Line.LNX.4.64.0703060942180.22674@d.namei> <1173192336.5415.5.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail6.sea5.speakeasy.net ([69.17.117.8]:47651 "EHLO
	mail6.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965914AbXCFPGE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 10:06:04 -0500
In-Reply-To: <1173192336.5415.5.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 6 Mar 2007, Johannes Berg wrote:

> This patch fixes a typo in compat_sock_common_getsockopt.
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
> 
> --- wireless-dev.orig/net/core/sock.c	2007-03-06 15:44:15.618565674 +0100
> +++ wireless-dev/net/core/sock.c	2007-03-06 15:44:25.948565674 +0100
> @@ -1597,7 +1597,7 @@ int compat_sock_common_getsockopt(struct
>  {
>  	struct sock *sk = sock->sk;
>  
> -	if (sk->sk_prot->compat_setsockopt != NULL)
> +	if (sk->sk_prot->compat_getsockopt != NULL)
>  		return sk->sk_prot->compat_getsockopt(sk, level, optname,
>  						      optval, optlen);
>  	return sk->sk_prot->getsockopt(sk, level, optname, optval, optlen);


Acked-by: James Morris <jmorris@namei.org>




-- 
James Morris
<jmorris@namei.org>
