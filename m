From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: gro: dev_gro_receive() cleanup
Date: Tue, 11 Dec 2012 12:51:11 -0500 (EST)
Message-ID: <20121211.125111.1548335816285987352.davem@davemloft.net>
References: <1355182096.27891.93.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41046 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753735Ab2LKRvM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2012 12:51:12 -0500
In-Reply-To: <1355182096.27891.93.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 10 Dec 2012 15:28:16 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> __napi_gro_receive() is inlined from two call sites for no good reason.
> 
> Lets move the prep stuff in a function of its own, called only if/when 
> needed. This saves 300 bytes on x86 :
> 
> # size net/core/dev.o.after net/core/dev.o.before
>    text	   data	    bss	    dec	    hex	filename
>   51968	   1238	   1040	  54246	   d3e6	net/core/dev.o.before
>   51664	   1238	   1040	  53942	   d2b6	net/core/dev.o.after
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
