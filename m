From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v4 1/4] Clean up indentation in net/ipv6/transp_v6.h
Date: Fri, 31 May 2013 18:25:40 -0700
Message-ID: <1370049940.10556.100.camel@joe-AO722>
References: <1370048750-28441-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Vasiliy Kulikov <segoon@openwall.com>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:53665 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753129Ab3FABZl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 May 2013 21:25:41 -0400
In-Reply-To: <1370048750-28441-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-06-01 at 10:05 +0900, Lorenzo Colitti wrote:
> Reduce the indentation of most of the functions and make it a
> bit more consistent. This allows longer function and arg names
> to be consistently indented without wrapping.
[]
> diff --git a/include/net/transp_v6.h b/include/net/transp_v6.h
[]
> @@ -7,47 +7,47 @@
[]
>  /* extension headers */
> -extern int				ipv6_exthdrs_init(void);
[]
> +extern int		ipv6_exthdrs_init(void);

externs aren't useful here and I suggest prototypes like
int ipv6_exthdrs_init(void);

> -extern int			ip6_datagram_send_ctl(struct net *net,
> -						      struct sock *sk,
> -						      struct msghdr *msg,
> -						      struct flowi6 *fl6,
> -						      struct ipv6_txoptions *opt,
> -						      int *hlimit, int *tclass,
> -						      int *dontfrag);
[]
> +extern int		ip6_datagram_send_ctl(struct net *net,
> +					      struct sock *sk,
> +					      struct msghdr *msg,
> +					      struct flowi6 *fl6,
> +					      struct ipv6_txoptions *opt,
> +					      int *hlimit, int *tclass,
> +					      int *dontfrag);

int ip6_datagram_send_ctl(struct net *net, struct sock *sk, struct msghdr *msg,
			  struct flowi6 *fl6, struct ipv6_txoptions *opt,
			  int *hlimit, int *tclass, int *dontfrag);

etc...

kernel_doc might be nice too
