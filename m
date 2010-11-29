From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] kthread: NUMA aware kthread_create_on_cpu()
Date: Mon, 29 Nov 2010 17:03:56 +0800
Message-ID: <20101129090356.GG5218@cr0.nay.redhat.com>
References: <1290972833.29196.90.camel@edumazet-laptop>
 <20101128224024.GA12300@basil.fritz.box>
 <1290984712.29196.100.camel@edumazet-laptop>
 <20101128230146.GB12300@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, Tejun Heo <tj@kernel.org>,
	Rusty Russell <rusty@rustcorp.com.au>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101128230146.GB12300@basil.fritz.box>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 29, 2010 at 12:01:47AM +0100, Andi Kleen wrote:
>
>task_struct is always allocated from slab.
>

IA64 is an exception, it has its own alloc_task_struct()
which is simply __get_free_pages().
