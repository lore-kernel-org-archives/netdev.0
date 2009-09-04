From: David Miller <davem@davemloft.net>
Subject: Re: [Patch -next] Fix net/3c503.c build break
Date: Fri, 04 Sep 2009 03:41:24 -0700 (PDT)
Message-ID: <20090904.034124.45872368.davem@davemloft.net>
References: <20090904182309.dbb05c96.sfr@canb.auug.org.au>
	<4AA0ED92.6070306@in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org
To: sachinp@in.ibm.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <4AA0ED92.6070306@in.ibm.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sachin Sant <sachinp@in.ibm.com>
Date: Fri, 04 Sep 2009 16:06:02 +0530

> Today's Next failed to build on a x86 box with following error.
> 
> drivers/net/3c503.c: In function 'el2_open':
> drivers/net/3c503.c:406: error: 'reval' undeclared (first use in this
> function)
> drivers/net/3c503.c:406: error: (Each undeclared identifier is
> reported only once
> drivers/net/3c503.c:406: error: for each function it appears in.)
> 
> Most probably because of commit
> ab08999d6029bb2c79c16be5405d63d2bedbdfea
> The patch had a typo in it. Below patch fixes the issue for me.

Applied, thank you.
