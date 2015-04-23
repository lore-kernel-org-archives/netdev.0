From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix tcp fin memory accounting
Date: Thu, 23 Apr 2015 11:54:47 -0400 (EDT)
Message-ID: <20150423.115447.2163146250304402014.davem@davemloft.net>
References: <1429661349.18561.23.camel@edumazet-glaptop2.roam.corp.google.com>
	<5538F821.6070503@akamai.com>
	<1429797767.22254.41.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johunt@akamai.com, netdev@vger.kernel.org, edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42140 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965646AbbDWPyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 11:54:50 -0400
In-Reply-To: <1429797767.22254.41.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 23 Apr 2015 07:02:47 -0700

> +		if (!tcp_send_head(sk)) {
> +			tp->snd_nxt++;
> +			return;
> +		}

I'm not so sure about this.  Why is this needed?

Otherwise patch looks fine to me.
