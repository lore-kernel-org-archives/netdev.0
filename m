From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net 1/3] ipv4: call __ip_options_echo() in
 cookie_v4_check()
Date: Fri, 17 Oct 2014 12:18:21 -0400 (EDT)
Message-ID: <20141017.121821.1367483767179008009.davem@davemloft.net>
References: <1413408802-21052-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kkolasa@winsoft.pl, edumazet@google.com,
	cwang@twopensource.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40812 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752032AbaJQQSX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 12:18:23 -0400
In-Reply-To: <1413408802-21052-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Wed, 15 Oct 2014 14:33:20 -0700

> From: Cong Wang <cwang@twopensource.com>
> 
> commit 971f10eca186cab238c49da ("tcp: better TCP_SKB_CB layout to reduce cache line misses")
> missed that cookie_v4_check() still calls ip_options_echo() which uses
> IPCB(). It should use TCPCB() at TCP layer, so call __ip_options_echo()
> instead.
> 
> Fixes: commit 971f10eca186cab238c49da ("tcp: better TCP_SKB_CB layout to reduce cache line misses")
> Cc: Krzysztof Kolasa <kkolasa@winsoft.pl>
> Cc: Eric Dumazet <edumazet@google.com>
> Reported-by: Krzysztof Kolasa <kkolasa@winsoft.pl>
> Tested-by: Krzysztof Kolasa <kkolasa@winsoft.pl>
> Signed-off-by: Cong Wang <cwang@twopensource.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied.
