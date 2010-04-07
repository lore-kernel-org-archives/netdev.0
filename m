From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Tue, 06 Apr 2010 20:12:20 -0700 (PDT)
Message-ID: <20100406.201220.195404728.davem@davemloft.net>
References: <20100407125817.e8e1d174.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, dm@chelsio.com, jpirko@redhat.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100407125817.e8e1d174.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 7 Apr 2010 12:58:17 +1000

> After merging the wireless tree, today's linux-next build (x86_64 allmodconfig)
> failed like this:
> 
> drivers/net/cxgb4/cxgb4_main.c: In function 'set_addr_filters':
> drivers/net/cxgb4/cxgb4_main.c:264: error: dereferencing pointer to incomplete type
> drivers/net/cxgb4/cxgb4_main.c:265: error: dereferencing pointer to incomplete type
> 
> Caused by commit b8ff05a9c3237f694a1c3bf8ceec3bf6c3c14b15 ("cxgb4: Add
> main driver file and driver Makefile") from Linus' tree interacting with
> commit 22bedad3ce112d5ca1eaf043d4990fa2ed698c87 ("net: convert multicast
> list to list_head").  The latter removed struct dev_addr_list.
> 
> I have reverted commit b8ff05a9c3237f694a1c3bf8ceec3bf6c3c14b15 (and
> 43e9da8d782b8a40d5127fcc59ac2e543cf16d7d ("net: Hook up cxgb4 to Kconfig
> and Makefile") that depended on it) for today.

Thanks, I'll merge net-2.6 into net-next-2.6 and fix this build
failure in the latter.
