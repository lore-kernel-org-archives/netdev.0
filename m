From: Julia Lawall <julia.lawall@lip6.fr>
Subject: question about drivers/net/ethernet/sgi
Date: Tue, 13 Aug 2013 17:43:32 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1308131742100.2263@hadrien>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: ralf@linux-mips.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:34724
	"EHLO mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758226Ab3HMPnw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 11:43:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The files in drivers/net/ethernet/sgi (meth.c and ioc3-eth.c) both use
alloc_skb.  Is there a reason why they do not use netdev_alloc_skb, like
most other ethernet drivers?

thanks,
julia
