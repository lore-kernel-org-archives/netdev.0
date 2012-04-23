From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Mon, 23 Apr 2012 00:25:20 -0400 (EDT)
Message-ID: <20120423.002520.995859309070448490.davem@davemloft.net>
References: <20120423121451.c88c9bfaaf4d79313f7219f3@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, ebiederm@xmission.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20120423121451.c88c9bfaaf4d79313f7219f3@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 23 Apr 2012 12:14:51 +1000

> After merging the net-next tree, today's linux-next build (x86_64
> allmodconfig) failed like this:
> 
> net/ax25/af_ax25.c: In function 'ax25_exit':
> net/ax25/af_ax25.c:2015:2: error: implicit declaration of function 'ax25_unregister_sysctl' [-Werror=implicit-function-declaration]
> 
> Caused by a mismerge between commit 3adadc08cc1e ("net ax25: Reorder
> ax25_exit to remove races") from the net tree and commit 0ca7a4c87d27
> ("net ax25: Simplify and cleanup the ax25 sysctl handling") from the
> net-next tree.
> 
> I have applied the following merge fix patch:

Looks correct, and I'll resolve this the next time I pull
net into net-next.

Thanks!
