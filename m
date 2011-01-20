From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: add a missing include in nf_conntrack_reasm.c
Date: Thu, 20 Jan 2011 20:18:27 +0100
Message-ID: <4D388A83.5020501@trash.net>
References: <1295545997.2825.458.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
	KOVACS Krisztian <hidden@balabit.hu>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1295545997.2825.458.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 20.01.2011 18:53, schrieb Eric Dumazet:
> After commit ae90bdeaeac6b (netfilter: fix compilation when conntrack is
> disabled but tproxy is enabled) we have following warnings :
> 
> net/ipv6/netfilter/nf_conntrack_reasm.c:520:16: warning: symbol
> 'nf_ct_frag6_gather' was not declared. Should it be static?
> net/ipv6/netfilter/nf_conntrack_reasm.c:591:6: warning: symbol
> 'nf_ct_frag6_output' was not declared. Should it be static?
> net/ipv6/netfilter/nf_conntrack_reasm.c:612:5: warning: symbol
> 'nf_ct_frag6_init' was not declared. Should it be static?
> net/ipv6/netfilter/nf_conntrack_reasm.c:640:6: warning: symbol
> 'nf_ct_frag6_cleanup' was not declared. Should it be static?
> 
> Fix this including net/netfilter/ipv6/nf_defrag_ipv6.h
> 

I currently don't have access to all my trees, does this patch
apply to 2.6.38 or just the current -rc?
