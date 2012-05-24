From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2] ipv4: fix the rcu race between free_fib_info and
 ip_route_output_slow
Date: Thu, 24 May 2012 00:27:29 -0400 (EDT)
Message-ID: <20120524.002729.1984174187865627892.davem@davemloft.net>
References: <4FBD9161.3040206@intel.com>
	<1337827362.3361.3800.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kunx.jiang@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, yanmin_zhang@linux.intel.com
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1337827362.3361.3800.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 24 May 2012 04:42:42 +0200

> On Thu, 2012-05-24 at 09:39 +0800, kun.jiang wrote:
>> From: Yanmin Zhang <yanmin_zhang@linux.intel.com>
>> 
>> We hit a kernel OOPS.
>> 
> ...
>> 
>> Function free_fib_info resets nexthop_nh->nh_dev to NULL before releasing
>> fi. Other cpu might be accessing fi. Fixing it by delaying the releasing.
>> 
>> With the patch, we ran MTBF testing on Android mobile for 12 hours
>> and didn't trigger the issue.
>> 
>> Thank Eric for very detailed review/checking the issue.
>> 
>> Signed-off-by: Yanmin Zhang <yanmin_zhang@linux.intel.com>
>> Signed-off-by: Kun Jiang <kunx.jiang@intel.com>
>> ---
>>  net/ipv4/fib_semantics.c |   12 ++++++------
>>  1 files changed, 6 insertions(+), 6 deletions(-)
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, thanks everyone.
