From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 01/11] ipv6: Do route updating for redirect in ndisc layer
Date: Thu, 12 Sep 2013 23:54:26 +0200
Message-ID: <20130912215426.GB2101@order.stressinduktion.org>
References: <52319A6E.6090503@cn.fujitsu.com> <52319AEC.1010206@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:54379 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752223Ab3ILVy1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 17:54:27 -0400
Content-Disposition: inline
In-Reply-To: <52319AEC.1010206@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 12, 2013 at 06:43:56PM +0800, Duan Jiong wrote:
> -
> -void ip6_sk_redirect(struct sk_buff *skb, struct sock *sk)
> -{
> -	ip6_redirect(skb, sock_net(sk), sk->sk_bound_dev_if, sk->sk_mark);
> -}
> -EXPORT_SYMBOL_GPL(ip6_sk_redirect);
> +EXPORT_SYMBOL_GPL(ip6_redirect);
>  
>  static unsigned int ip6_default_advmss(const struct dst_entry *dst)
>  {

This breaks bisectability. Please remove the function after you cleared up all
references to it. Otherwise git bisect would throw compiler errors.

Greetings,

  Hannes
