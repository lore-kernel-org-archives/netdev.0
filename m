From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Sun, 14 Feb 2010 22:22:11 -0800 (PST)
Message-ID: <20100214.222211.91409708.davem@davemloft.net>
References: <20100215152009.c8f9949c.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, peter.p.waskiewicz.jr@intel.com,
	jeffrey.t.kirsher@intel.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100215152009.c8f9949c.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 15 Feb 2010 15:20:09 +1100

> After merging the net tree, today's linux-next build (x86_64 allmodconfig)
> failed like this:
> 
> usr/include/linux/ethtool.h:17: included file 'linux/rculist.h' is not exported
> 
> Caused by commit 15682bc488d4af8c9bb998844a94281025e0a333 ("ethtool:
> Introduce n-tuple filter programming support").
> 
> I have used the version of the net tree from next-20100212 for today.

I have a fix for that in my queue, thanks for reporting.
