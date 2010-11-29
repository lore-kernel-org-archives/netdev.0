From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 4/4] kthread: use kthread_create_on_cpu()
Date: Mon, 29 Nov 2010 16:19:09 +0100
Message-ID: <4CF3C46D.9030800@kernel.org>
References: <1290972833.29196.90.camel@edumazet-laptop>	 <20101128224024.GA12300@basil.fritz.box>	 <1290984712.29196.100.camel@edumazet-laptop>	 <20101128230146.GB12300@basil.fritz.box>	 <1290987424.29196.128.camel@edumazet-laptop>	 <20101129090510.GA15763@basil.fritz.box>	 <1291023532.3435.29.camel@edumazet-laptop> <1291043719.3435.981.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Rusty Russell <rusty@rustcorp.com.au>,
	linux-arch@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1291043719.3435.981.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/29/2010 04:15 PM, Eric Dumazet wrote:
> ksoftirqd, kworker, migration, and pktgend kthreads can be created with
> kthread_create_on_cpu(), to get proper NUMA affinities for their stack
> and task_struct.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: David Miller <davem@davemloft.net>
> Cc: Andi Kleen <andi@firstfloor.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: linux-arch@vger.kernel.org

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun
