From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Mon, 14 Jun 2010 19:13:56 -0700 (PDT)
Message-ID: <20100614.191356.193722104.davem@davemloft.net>
References: <20100615120052.7202f20d.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, andy@greyhouse.net,
	emil.s.tantilov@intel.com, jeffrey.t.kirsher@intel.com
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100615120052.7202f20d.sfr@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 15 Jun 2010 12:00:52 +1000

> Hi Dave,
> 
> After merging the wireless tree, today's linux-next build (powerpc ppc64_defconfig)
> failed like this:
> 
> drivers/net/ixgbe/ixgbe_ethtool.c: In function 'ixgbe_set_flags':
> drivers/net/ixgbe/ixgbe_ethtool.c:2232: error: implicit declaration of function 'DPRINTK'
> drivers/net/ixgbe/ixgbe_ethtool.c:2232: error: 'PROBE' undeclared (first use in this function)
> drivers/net/ixgbe/ixgbe_ethtool.c:2232: error: 'INFO' undeclared (first use in this function)
> 
> Commit 28c8e4790ca5ef75f54895ca46437f9fbb433ddf ("ixgbe: fix automatic
> LRO/RSC settings for low latency") from the net-current tree added
> another use of DPRINTK which needs comverting to e_info().  I applied the
> following patch:
> 
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Tue, 15 Jun 2010 11:43:33 +1000
> Subject: [PATCH] net: ixgbe_ethtool merge fix up
> 
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>

I'll incorporate your merge and build fixups when I merge net-2.6 into
net-next-2.6 later tonight, thanks Stephen!
