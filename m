From: David Miller <davem@davemloft.net>
Subject: Re: [TCP]: TCP_DEFER_ACCEPT causes leak sockets
Date: Tue, 17 Jun 2008 02:08:40 -0700 (PDT)
Message-ID: <20080617.020840.169830916.davem@davemloft.net>
References: <20080617.003832.130616157.davem@davemloft.net>
	<20080617080958.GC12535@elte.hu>
	<20080617083220.GA11393@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, vgusev@openvz.org, mcmanus@ducksong.com,
	xemul@openvz.org, netdev@vger.kernel.org,
	ilpo.jarvinen@helsinki.fi, linux-kernel@vger.kernel.org,
	e1000-devel@lists.sourceforge.net, rjw@sisk.pl
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51181
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750873AbYFQJIj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 05:08:39 -0400
In-Reply-To: <20080617083220.GA11393@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Tue, 17 Jun 2008 10:32:20 +0200

> those up to 1000 msec delays can be 'felt' via ssh too, if this problem 
> triggers then the system is almost unusable via the network. Local 
> latencies are perfect so it's an e1000 problem.

Or some kind of weird interrupt problem.

Such an interrupt level bug would also account for the TX timeout's
you're seeing btw.
