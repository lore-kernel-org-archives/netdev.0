From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: avoid wakeups for pure ACK
Date: Wed, 27 Feb 2013 16:15:52 -0500 (EST)
Message-ID: <20130227.161552.102016616709396662.davem@davemloft.net>
References: <1361984703.11403.43.camel@edumazet-glaptop>
	<20130227.130444.2188252064827683663.davem@davemloft.net>
	<1361989059.11403.50.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, therbert@google.com,
	ycheng@google.com, ak@linux.intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32946 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750699Ab3B0VPy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 16:15:54 -0500
In-Reply-To: <1361989059.11403.50.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 27 Feb 2013 10:17:39 -0800

> So this patch will also help this (not very usual) situation, as we will
> only wakeup the tcp_sendmsg() thread when ACK is processed from softirq
> handler, and let the thread blocked in tcp_recvmsg() sleeping.

Ok, thanks for the analysis.
