From: David Miller <davem@davemloft.net>
Subject: Re: [patch] net/core/filter.c: Fix build error
Date: Thu, 26 May 2011 15:00:57 -0400 (EDT)
Message-ID: <20110526.150057.165386141746439600.davem@davemloft.net>
References: <1306423866.16087.10.camel@Joe-Laptop>
	<20110526.143843.205897228685761536.davem@davemloft.net>
	<20110526115721.ee83aefc.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, mingo@elte.hu, greearb@candelatech.com,
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	arnd@arndb.de, netdev@vger.kernel.org
To: randy.dunlap@oracle.com
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20110526115721.ee83aefc.randy.dunlap@oracle.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Thu, 26 May 2011 11:57:21 -0700

> On Thu, 26 May 2011 14:38:43 -0400 (EDT) David Miller wrote:
> 
>> From: Joe Perches <joe@perches.com>
>> Date: Thu, 26 May 2011 08:31:06 -0700
>> 
>> > My suggestion would be to see about again adding
>> > #include <linux/ratelimit.h> somehow
>> > back to kernel.h which commit 3fff4c42bd0a removed
>> > in 2009 because of the spinlock issues.
>> > 
>> > Any suggestion on how best to fix it generically?
>> 
>> I don't think we want spinlock_t's definition being sucked
>> into kernel.h's dependency food chain.
>> 
>> Even if desirable, I think it'd be quite a bit of surgery,
>> too much to do at this stage.
>> 
>> So for now how about we make the ratelimit warn interfaces be a true,
>> instead of a pseudo, dependency on ratelimit.h by moving those
>> definitions into ratelimit.h?
> 
> Works for me.  Thanks.
> 
> Acked-by: Randy Dunlap <randy.dunlap@oracle.com>

Thanks for reviewing Randy, I've put this into net-2.6 and will
push it out to Linus soon.
