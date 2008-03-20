From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Re: netconsole still hangs
Date: Thu, 20 Mar 2008 16:08:46 -0700 (PDT)
Message-ID: <20080320.160846.71909746.davem@davemloft.net>
References: <20080312235205.dcec2d35.akpm@linux-foundation.org>
	<20080314234749.GA10606@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, rjw@sisk.pl
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40380
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753793AbYCTXI3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 19:08:29 -0400
In-Reply-To: <20080314234749.GA10606@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Sat, 15 Mar 2008 00:47:49 +0100

> [NETPOLL] zap_completion_queue: adjust skb->users counter
> 
> zap_completion_queue() retrieves skbs from completion_queue where they
> have zero skb->users counter. Before dev_kfree_skb_any() it should be
> non-zero yet, so it's increased now.
> 
> 
> Reported-and-tested-by: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

I've applied this, thanks everyone.

I'll queue it up for -stable too.
