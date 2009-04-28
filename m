From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netfilter: use per-CPU r**ursive lock {XV}
Date: Tue, 28 Apr 2009 07:37:59 -0700 (PDT)
Message-ID: <20090428.073759.78537345.davem@davemloft.net>
References: <20090428124033.GA1655@elte.hu>
	<20090428.064340.193569214.davem@davemloft.net>
	<20090428135219.GA28513@Krystal>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, dada1@cosmosbay.com, torvalds@linux-foundation.org,
	shemminger@vyatta.com, zbr@ioremap.net, peterz@infradead.org,
	jarkao2@gmail.com, paulus@samba.org, paulmck@linux.vnet.ibm.com,
	kaber@trash.net, jeff.chua.linux@gmail.com, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: mathieu.desnoyers@polymtl.ca
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090428135219.GA28513@Krystal>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Date: Tue, 28 Apr 2009 09:52:19 -0400

> The local_bh_disable() could be outside of the locking construct. This
> would make it easier to adapt it to various users (irq disable, bh
> disable, preempt disable) depending on the contexts from which they much
> be protected.
> 
> And if it still does not work for some reason, using a #define is
> discouraged, but could work.

That's what I was hoping to avoid, things like macros and having
the callers of this thing expand the two parts of the operation.

What's the point in making this generic if it ends up being ugly
as hell?
