From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] pkt_sched: Change PSCHED_SHIFT from 10 to 6
Date: Tue, 09 Jun 2009 05:21:29 -0700 (PDT)
Message-ID: <20090609.052129.146632593.davem@davemloft.net>
References: <20090609080513.GB5237@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, vexwek@gmail.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, devik@cdi.cz, dada1@cosmosbay.com,
	hazard@francoudi.com, slavon@bigtelecom.ru
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41137
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755848AbZFIMV1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 08:21:27 -0400
In-Reply-To: <20090609080513.GB5237@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Tue, 9 Jun 2009 08:05:13 +0000

> Change PSCHED_SHIFT from 10 to 6 to increase schedulers time
> resolution. This will increase 16x a number of (internal) ticks per
> nanosecond, and is needed to improve accuracy of schedulers based on
> rate tables, like HTB, TBF or CBQ, with rates above 100Mbit. It is
> assumed this change is safe for 32bit accounting of time diffs up
> to 2 minutes, which should be enough for common use (extremely low
> rate values may overflow, so get inaccurate instead). To make full
> use of this change an updated iproute2 will be needed. (But using
> older iproute2 should be safe too.)
> 
> This change breaks ticks - microseconds similarity, so some minor code
> fixes might be needed. It is also planned to change naming adequately
> eg. to PSCHED_TICKS2NS() etc. in the near future.
> 
> Reported-by: Antonio Almeida <vexwek@gmail.com>
> Tested-by: Antonio Almeida <vexwek@gmail.com>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied.
