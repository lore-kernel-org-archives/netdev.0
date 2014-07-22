From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv4: fix buffer overflow in ip_options_compile()
Date: Mon, 21 Jul 2014 20:17:26 -0700 (PDT)
Message-ID: <20140721.201726.119337265768368434.davem@davemloft.net>
References: <1405919862.10255.109.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40586 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751308AbaGVDRu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 23:17:50 -0400
In-Reply-To: <1405919862.10255.109.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 21 Jul 2014 07:17:42 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> There is a benign buffer overflow in ip_options_compile spotted by
> AddressSanitizer[1] :
> 
> Its benign because we always can access one extra byte in skb->head
> (because header is followed by struct skb_shared_info), and in this case
> this byte is not even used.
 ...
> [1] https://code.google.com/p/address-sanitizer/wiki/AddressSanitizerForKernel
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Right, should be benign, but I will queue it up to -stable anyways
just to be safe.

Applied, thanks a lot Eric.
