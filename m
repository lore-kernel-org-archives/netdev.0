From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net 2/3] ipv4: share tcp_v4_save_options() with
 cookie_v4_check()
Date: Fri, 17 Oct 2014 12:18:26 -0400 (EDT)
Message-ID: <20141017.121826.1494309580909095575.davem@davemloft.net>
References: <1413408802-21052-1-git-send-email-xiyou.wangcong@gmail.com>
	<1413408802-21052-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kkolasa@winsoft.pl, edumazet@google.com,
	cwang@twopensource.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40818 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753154AbaJQQS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 12:18:28 -0400
In-Reply-To: <1413408802-21052-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Wed, 15 Oct 2014 14:33:21 -0700

> From: Cong Wang <cwang@twopensource.com>
> 
> cookie_v4_check() allocates ip_options_rcu in the same way
> with tcp_v4_save_options(), we can just make it a helper function.
> 
> Cc: Krzysztof Kolasa <kkolasa@winsoft.pl>
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Cong Wang <cwang@twopensource.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied.
