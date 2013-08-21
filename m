From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build warning after merge of the net-next tree
Date: Wed, 21 Aug 2013 11:15:00 -0700 (PDT)
Message-ID: <20130821.111500.578777610906041340.davem@davemloft.net>
References: <20130821191041.712893827d8000c6dca8781b@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, dingtianhong@huawei.com
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130821191041.712893827d8000c6dca8781b@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 21 Aug 2013 19:10:41 +1000

> Hi all,
> 
> After merging the net-next tree, today's linux-next build (i386 defconfig
> and probably others) produced this warning:
> 
> net/ipv6/addrconf.c: In function 'addrconf_notify':
> net/ipv6/addrconf.c:2793:22: warning: 'link_dev' may be used uninitialized in this function [-Wuninitialized]
> net/ipv6/addrconf.c:2802:21: note: 'link_dev' was declared here
> 
> Introduced by commit df8372ca747f ("ipv6: fix checkpatch errors in
> net/ipv6/addrconf.c").  It looks like here are some missing braces.

Yes, which has since been reverted.
