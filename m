From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdev: Fix sleeping inside wait event
Date: Wed, 29 Oct 2014 13:38:43 -0400 (EDT)
Message-ID: <20141029.133843.1944866828262153726.davem@davemloft.net>
References: <CAM_iQpXTyBT_4TrnYAoAuAE_jMto=2B=cutFggpHRMhvSrG7qg@mail.gmail.com>
	<20141029171345.GO12706@worktop.programming.kicks-ass.net>
	<20141029173110.GE15602@worktop.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, fengguang.wu@intel.com, lkp@01.org,
	linux-kernel@vger.kernel.org, oleg@redhat.com,
	ebiederm@xmission.com, netdev@vger.kernel.org
To: peterz@infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141029173110.GE15602@worktop.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 29 Oct 2014 18:31:10 +0100

> On Wed, Oct 29, 2014 at 06:13:45PM +0100, Peter Zijlstra wrote:
>> On Wed, Oct 29, 2014 at 09:29:55AM -0700, Cong Wang wrote:
>> > While you are on it, please fix rtnl_lock_unregistering_all() too?
>> 
>> Ah, that's hidden someplace else, sure I can do that. Thanks for
>> pointing it out.
> 
> Here goes..

For this as well:

Acked-by: David S. Miller <davem@davemloft.net>
