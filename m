From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] l2tp: fix race while getting PMTU on PPP
 pseudo-wire
Date: Fri, 05 Sep 2014 14:41:25 -0700 (PDT)
Message-ID: <20140905.144125.1368697780523222565.davem@davemloft.net>
References: <3a4673ddb2556634d0cbeae9b31ebc386e720335.1409746289.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56385 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752588AbaIEVl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 17:41:27 -0400
In-Reply-To: <3a4673ddb2556634d0cbeae9b31ebc386e720335.1409746289.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Wed, 3 Sep 2014 14:12:55 +0200

> Use dst_entry held by sk_dst_get() to retrieve tunnel's PMTU.
> 
> The dst_mtu(__sk_dst_get(tunnel->sock)) call was racy. __sk_dst_get()
> could return NULL if tunnel->sock->sk_dst_cache was reset just before the
> call, thus making dst_mtu() dereference a NULL pointer:
 ...
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>

Applied and queued up for -stable, thanks!
