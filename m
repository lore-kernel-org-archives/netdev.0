From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] net: block BH in TCP callbacks
Date: Thu, 19 May 2016 11:37:13 -0700 (PDT)
Message-ID: <20160519.113713.1974239749897301374.davem@davemloft.net>
References: <1463532249-20850-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, venkateshs@google.com,
	eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42293 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933486AbcESShO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 14:37:14 -0400
In-Reply-To: <1463532249-20850-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Tue, 17 May 2016 17:44:05 -0700

> Four layers using TCP stack were assuming sk_callback_lock could
> be locked using read_lock() in their handlers because TCP stack
> was running with BH disabled.
> 
> This is no longer the case. Since presumably the rest could
> also depend on BH being disabled, just use read_lock_bh().
> 
> Then each layer might consider switching to RCU protection
> and no longer depend on BH.

Series applied, thanks Eric.
