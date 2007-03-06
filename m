From: James Morris <jmorris@namei.org>
Subject: Re: compat_sock_common_getsockopt typo?
Date: Tue, 6 Mar 2007 09:43:05 -0500 (EST)
Message-ID: <Line.LNX.4.64.0703060942180.22674@d.namei>
References: <1173137211.15891.27.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail8.sea5.speakeasy.net ([69.17.117.10]:54694 "EHLO
	mail8.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965883AbXCFOnI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 09:43:08 -0500
In-Reply-To: <1173137211.15891.27.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 6 Mar 2007, Johannes Berg wrote:

> The function reads as follows:
> 
> int compat_sock_common_getsockopt(struct socket *sock, int level, int optname,
>                                   char __user *optval, int __user *optlen)
> {
>         struct sock *sk = sock->sk;
> 
>         if (sk->sk_prot->compat_setsockopt != NULL)
>                                 ^^^
> 
>                 return sk->sk_prot->compat_getsockopt(sk, level, optname,
>                                            ^^^
>                                                       optval, optlen);
>         return sk->sk_prot->getsockopt(sk, level, optname, optval, optlen);
> }
> EXPORT_SYMBOL(compat_sock_common_getsockopt);
> 
> Is that intentional to make protocol writers assign both if they want
> compat_setsockopt? :P

It's a bug.



-- 
James Morris
<jmorris@namei.org>
