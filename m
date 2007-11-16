From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET : convert ip_rt_acct to per_cpu variables
Date: Fri, 16 Nov 2007 03:32:38 -0800 (PST)
Message-ID: <20071116.033238.167839530.davem@davemloft.net>
References: <20071116.011243.48184084.davem@davemloft.net>
	<20071116103546.8320d985.dada1@cosmosbay.com>
	<20071116115852.518b696d.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33894
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751746AbXKPLcj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2007 06:32:39 -0500
In-Reply-To: <20071116115852.518b696d.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 16 Nov 2007 11:58:52 +0100

> [PATCH] NET : NET_CLS_ROUTE : convert ip_rt_acct to per_cpu variables
> 
> ip_rt_acct needs 4096 bytes per cpu to perform some accounting.
> It is actually allocated as a single huge array [4096*NR_CPUS]
> (rounded up to a power of two)
> 
> Converting it to a per cpu variable is wanted to :
>  - Save space on machines were num_possible_cpus() < NR_CPUS
>  - Better NUMA placement (each cpu gets memory on its node)
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied to net-2.6.25, thanks Eric.
