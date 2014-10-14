From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC v4 net 1/3] ipv6: Remove BACKTRACK macro
Date: Tue, 14 Oct 2014 15:01:06 -0400 (EDT)
Message-ID: <20141014.150106.2250383188165649088.davem@davemloft.net>
References: <1412966888-31384-1-git-send-email-kafai@fb.com>
	<1412966888-31384-2-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43659 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753601AbaJNTBI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 15:01:08 -0400
In-Reply-To: <1412966888-31384-2-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Fri, 10 Oct 2014 11:48:06 -0700

> +struct fib6_node *fib6_backtrack(struct fib6_node *fn,
> +				 struct in6_addr *saddr);
> +

I am completely mystified why you did this, could you explain the
logic?  I want to know what drove you to make this exported.

I marked it static in my example patch, and there is no caller outside
of route.c

Doing this also eliminates inlining opportunitites.

Please keep this private inside of route.c
