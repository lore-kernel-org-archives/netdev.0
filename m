From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] net_sched: htb: support of 64bit rates
Date: Fri, 20 Sep 2013 14:42:46 -0400 (EDT)
Message-ID: <20130920.144246.1733125926277807658.davem@davemloft.net>
References: <1379607020.3282.14.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39332 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753319Ab3ITSmr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Sep 2013 14:42:47 -0400
In-Reply-To: <1379607020.3282.14.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 19 Sep 2013 09:10:20 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> HTB already can deal with 64bit rates, we only have to add two new
> attributes so that tc can use them to break the current 32bit ABI
> barrier.
> 
> TCA_HTB_RATE64 : class rate  (in bytes per second)
> TCA_HTB_CEIL64 : class ceil  (in bytes per second)
> 
> This allows us to setup HTB on 40Gbps links, as 32bit limit is
> actually ~34Gbps
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
