From: Ravikiran G Thirumalai <kiran@scalex86.org>
Subject: Re: [patch 3/4] net: Percpufy frequently used variables -- proto.sockets_allocated
Date: Fri, 27 Jan 2006 14:50:36 -0800
Message-ID: <20060127225036.GC3565@localhost.localdomain>
References: <20060126185649.GB3651@localhost.localdomain> <20060126190357.GE3651@localhost.localdomain> <43D9DFA1.9070802@cosmosbay.com> <20060127195227.GA3565@localhost.localdomain> <20060127121602.18bc3f25.akpm@osdl.org> <43DA9EFF.1020200@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, davem@davemloft.net,
	linux-kernel@vger.kernel.org, shai@scalex86.org,
	netdev@vger.kernel.org, pravins@calsoftinc.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751586AbWA0Wug@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Content-Disposition: inline
In-Reply-To: <43DA9EFF.1020200@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 27, 2006 at 11:30:23PM +0100, Eric Dumazet wrote:
> 
> There are several issues here :
> 
> alloc_percpu() current implementation is a a waste of ram. (because it uses 
> slab allocations that have a minimum size of 32 bytes)

Oh there was a solution for that :).  

http://lwn.net/Articles/119532/

I can quickly revive it if there is interest.


Thanks,
Kiran
