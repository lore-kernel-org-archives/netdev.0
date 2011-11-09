From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V4 net-next] neigh: new unresolved queue limits
Date: Wed, 09 Nov 2011 16:21:37 -0500 (EST)
Message-ID: <20111109.162137.808999062815992591.davem@davemloft.net>
References: <1320837249.2315.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20111109.161644.505896539772671525.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37435 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754031Ab1KIVVk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2011 16:21:40 -0500
In-Reply-To: <20111109.161644.505896539772671525.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 09 Nov 2011 16:16:44 -0500 (EST)

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 09 Nov 2011 12:14:09 +0100
> 
>> unres_qlen is the number of frames we are able to queue per unresolved
>> neighbour. Its default value (3) was never changed and is responsible
>> for strange drops, especially if IP fragments are used, or multiple
>> sessions start in parallel. Even a single tcp flow can hit this limit.
>  ...
> 
> Ok, I've applied this, let's see what happens :-)

Early answer, build fails.

Please test build this patch with DECNET enabled and resubmit.  The
decnet neigh layer still refers to the removed ->queue_len member.

Thanks.
