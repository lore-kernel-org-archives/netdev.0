From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/2] netns: remove leftover debugging message
Date: Thu, 21 May 2009 14:39:11 -0700
Message-ID: <m1hbzeqgow.fsf@fess.ebiederm.org>
References: <20090521135846.1fadbe41@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:42985 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752749AbZEUVjO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2009 17:39:14 -0400
In-Reply-To: <20090521135846.1fadbe41@nehalam> (Stephen Hemminger's message of "Thu\, 21 May 2009 13\:58\:46 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> writes:

> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>

>
> --- a/net/core/net_namespace.c	2009-05-21 13:54:40.546518443 -0700
> +++ b/net/core/net_namespace.c	2009-05-21 13:55:25.519706614 -0700
> @@ -198,7 +198,6 @@ static int __init net_ns_init(void)
>  	struct net_generic *ng;
>  	int err;
>  
> -	printk(KERN_INFO "net_namespace: %zd bytes\n", sizeof(struct net));
>  #ifdef CONFIG_NET_NS
>  	net_cachep = kmem_cache_create("net_namespace", sizeof(struct net),
>  					SMP_CACHE_BYTES,
