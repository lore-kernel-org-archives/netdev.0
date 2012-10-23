From: David Miller <davem@davemloft.net>
Subject: Re: ipv4 gro receive IHL
Date: Tue, 23 Oct 2012 02:27:13 -0400 (EDT)
Message-ID: <20121023.022713.1744593948897349616.davem@davemloft.net>
References: <20121022.234606.1841113825492366676.davem@davemloft.net>
	<1350972094.8609.1420.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37259 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752595Ab2JWG1Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 02:27:16 -0400
In-Reply-To: <1350972094.8609.1420.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 23 Oct 2012 08:01:34 +0200

> GRO on IPv4 only supports ihl = 5, this is tested in :
> 
> if (*(u8 *)iph != 0x45)
>     goto out_unlock;
> 
> I also was planning to add some code to ip_fast_csum(addr, X) to have a
> fast path (no conditional jump) for the case where X is the constant 5

Oh indeed, thanks for clearing that up.
