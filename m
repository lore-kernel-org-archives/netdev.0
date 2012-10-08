From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 3/6] ipv4: add check if nh_pcpu_rth_output is
 allocated
Date: Mon, 08 Oct 2012 15:17:52 -0400 (EDT)
Message-ID: <20121008.151752.1431130692375532802.davem@davemloft.net>
References: <1349609168-9848-1-git-send-email-ja@ssi.bg>
	<1349609168-9848-4-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57115 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753841Ab2JHTRy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2012 15:17:54 -0400
In-Reply-To: <1349609168-9848-4-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Sun,  7 Oct 2012 14:26:05 +0300

> 	Avoid NULL ptr dereference and caching if
> nh_pcpu_rth_output is not allocated.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Ugh.

Checking for alloc_percpu() failures in fib_create_info() is 1,000
times better than doing stuff like this in the fast path.
