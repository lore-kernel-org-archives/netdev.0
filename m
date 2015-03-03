From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 01/14] etherdevice: Add eth_<foo>_addr
 CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS code
Date: Tue, 03 Mar 2015 14:58:15 -0500 (EST)
Message-ID: <20150303.145815.1129211297511474723.davem@davemloft.net>
References: <1425409671.17273.42.camel@perches.com>
	<20150303.142758.822602589629075339.davem@davemloft.net>
	<1425411669.17273.52.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425411669.17273.52.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Tue, 03 Mar 2015 11:41:09 -0800

> Until such time as the linux crosstools compilers are updated,
> (they seem stuck on 4.6.3 from 3 years ago)
> https://www.kernel.org/pub/tools/crosstool/
> I think the series is a trivial, small improvement.

You are even admitting that even for your specific case you are
using 3+ year old compiler technology.

These are slow paths, so correctness is the most important aspect.

Converting these locations to consistently use eth_*() is fine,
but then "optimizing" a 6 by memset for configuration paths when
the compiler should be more than capable of doing this just fine
is not convincing at all to me.
