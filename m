From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 01/14] etherdevice: Add eth_<foo>_addr
 CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS code
Date: Tue, 03 Mar 2015 17:01:57 -0500 (EST)
Message-ID: <20150303.170157.1158245155960991442.davem@davemloft.net>
References: <1425411669.17273.52.camel@perches.com>
	<20150303.145815.1129211297511474723.davem@davemloft.net>
	<1425413068.17273.58.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425413068.17273.58.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Tue, 03 Mar 2015 12:04:28 -0800

> On Tue, 2015-03-03 at 14:58 -0500, David Miller wrote:
>> From: Joe Perches <joe@perches.com>
>> Date: Tue, 03 Mar 2015 11:41:09 -0800
>> 
>> Converting these locations to consistently use eth_*() is fine,
>> but then "optimizing" a 6 by memset for configuration paths when
>> the compiler should be more than capable of doing this just fine
>> is not convincing at all to me.
> 
> Swell, then perhaps you could simply skip 1/14.

Yes, that's reasonable, applied to net-next.
