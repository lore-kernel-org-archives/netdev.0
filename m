From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Wed, 08 Dec 2010 18:39:42 -0800 (PST)
Message-ID: <20101208.183942.226776000.davem@davemloft.net>
References: <20101209132836.6f6acfb8.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, socketcan@hartkopp.net
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20101209132836.6f6acfb8.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 9 Dec 2010 13:28:36 +1100

> After merging the net tree, today's linux-next build (x86_64 allmodconfig)
> failed like this:
> 
> drivers/net/can/slcan.c: In function 'slcan_open':
> drivers/net/can/slcan.c:568: error: dereferencing pointer to incomplete type

That's amazing that with all the header files this driver includes,
powerpc somehow doesn't get the task_struct definition :-)

I'll add the obvious linux/sched.h include to fix this, thanks!
