From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: change inet_addr_hash()
Date: Sat, 04 Aug 2012 01:28:12 -0700 (PDT)
Message-ID: <20120804.012812.842569667363764548.davem@davemloft.net>
References: <1344064010.9299.1468.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43896 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753277Ab2HDI2N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Aug 2012 04:28:13 -0400
In-Reply-To: <1344064010.9299.1468.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 04 Aug 2012 09:06:50 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Use net_hash_mix(net) instead of hash_ptr(net, 8), and use
> hash_32() instead of using a serie of XOR
> 
> Define IN4_ADDR_HSIZE_SHIFT for clarity
> 
> __ip_dev_find() can perform the net_eq() call only if ifa_local
> matches the key, to avoid unneeded dereferences.
> 
> remove inline attributes
> 
> # size net/ipv4/devinet.o.before net/ipv4/devinet.o
>    text	   data	    bss	    dec	    hex	filename
>   17471	   2545	   2048	  22064	   5630	net/ipv4/devinet.o.before
>   17335	   2545	   2048	  21928	   55a8	net/ipv4/devinet.o
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
