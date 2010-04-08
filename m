From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the final tree
Date: Wed, 07 Apr 2010 23:25:00 -0700 (PDT)
Message-ID: <20100407.232500.184442638.davem@davemloft.net>
References: <20100408153505.eb205158.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, john.linn@xilinx.com,
	jtyner@cs.ucr.edu
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100408153505.eb205158.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 8 Apr 2010 15:35:05 +1000

> After merging the final tree, today's linux-next build (powerpc
> allyesconfig) failed like this:
> 
> drivers/net/ll_temac_main.c: In function 'll_temac_recv':
> drivers/net/ll_temac_main.c:695: error: implicit declaration of function 'virt_to_bus'
> 
> Caused by commit 459569145516f7967b916c57445feb02c600668c ("Add
> non-Virtex5 support for LL TEMAC driver") from the net tree.
> 
> I have reverted that commit for today.

And I'm reverting it too, it's illegal to use virt_to_bus()
in new code in this day and age.

John, you'll need to use the DMA mapping APIs in this change when you
resubmit it.

Thanks.
