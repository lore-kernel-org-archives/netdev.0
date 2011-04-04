From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Sun, 03 Apr 2011 19:43:01 -0700 (PDT)
Message-ID: <20110403.194301.232921375.davem@davemloft.net>
References: <20110404112840.98dd98ec.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, mirq-linux@rere.qmqm.pl
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110404112840.98dd98ec.sfr@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 4 Apr 2011 11:28:40 +1000

> Hi all,
> 
> After merging the net tree, today's linux-next build (x86_64 allmodconfig)
> failed like this:
> 
> drivers/net/xen-netfront.c:1151: error: 'xennet_fix_features' undeclared here (not in a function)
> drivers/net/xen-netfront.c:1152: error: 'xennet_set_features' undeclared here (not in a function)
> 
> Caused by commit fb507934fd6f ("net: convert xen-netfront to hw_features").

Just pushed a fix for this to net-next-2.6, sorry about that.
