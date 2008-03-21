From: David Miller <davem@davemloft.net>
Subject: Re: [14/14] vcompound: Avoid vmalloc for ehash_locks
Date: Fri, 21 Mar 2008 00:31:00 -0700 (PDT)
Message-ID: <20080321.003100.155729406.davem@davemloft.net>
References: <20080321061703.921169367@sgi.com>
	<20080321061727.491610308@sgi.com>
	<47E35D73.6060703@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40673
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753866AbYCUHas (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2008 03:30:48 -0400
In-Reply-To: <47E35D73.6060703@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 21 Mar 2008 08:02:11 +0100

> But, isnt it defeating the purpose of this *particular* vmalloc() use ?
> 
> CONFIG_NUMA and vmalloc() at boot time means :
> 
> Try to distribute the pages on several nodes.
> 
> Memory pressure on ehash_locks[] is so high we definitly want to spread it.
> 
> (for similar uses of vmalloc(), see also hashdist=1 )
> 
> Also, please CC netdev for network patches :)

I agree with Eric, converting any of the networking hash
allocations to this new facility is not the right thing
to do.
