From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netfilter: use per-CPU r**ursive lock {XV}
Date: Tue, 28 Apr 2009 04:53:42 -0700 (PDT)
Message-ID: <20090428.045342.206106171.davem@davemloft.net>
References: <alpine.LFD.2.00.0904271525120.22156@localhost.localdomain>
	<alpine.LFD.2.00.0904271602390.22156@localhost.localdomain>
	<49F6A8FD.3010804@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, shemminger@vyatta.com,
	zbr@ioremap.net, mingo@elte.hu, peterz@infradead.org,
	mathieu.desnoyers@polymtl.ca, jarkao2@gmail.com, paulus@samba.org,
	paulmck@linux.vnet.ibm.com, kaber@trash.net,
	jeff.chua.linux@gmail.com, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: dada1@cosmosbay.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <49F6A8FD.3010804@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 28 Apr 2009 08:58:05 +0200

> I am not sure my day job will permit me to polish a patch mixing all
> the bits and comments. But I am glad we eventually got back spinlocks
> which are probably better than rwlocks for implementing this stuff.
> 
> Instead of submitting a full patch again, we could first submit a new
>  include file containg all comments and inline functions ?
> 
> This include file could be local to netfilter, with a big stick on
> it to forbids its use on other areas (No changes in Documentation/ )
> 
> Then, as soon as we can go back to pure RCU solution, we can safely
> delete this controversial-locking-nesting-per-cpu-thing ?

I say we merge Linus's locking idea into the XV patch, fixup the
commit message wording, and move on with life.

For something that's going to get deleted as soon as the faster grace
period RCU stuff is available, it has consumed an inordinate amount of
our time :-)

I might take a stab at this before hittng bed tonight, no promises :)
