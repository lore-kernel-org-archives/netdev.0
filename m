From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] bridge: fix build for CONFIG_SYSFS disabled
Date: Tue, 18 May 2010 12:26:40 -0700 (PDT)
Message-ID: <20100518.122640.24579847.davem@davemloft.net>
References: <4BF18468.5010005@oracle.com>
	<20100517.223237.55871633.davem@davemloft.net>
	<20100518102837.2622c3b1@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: randy.dunlap@oracle.com, sfr@canb.auug.org.au,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100518102837.2622c3b1@nehalam>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 18 May 2010 10:28:37 -0700

> 
> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Fix build when CONFIG_SYSFS is not enabled:
> net/bridge/br_if.c:136: error: 'struct net_bridge_port' has no member named 'sysfs_name'
> 
> Note: dev->name == sysfs_name except when change name is in
> progress, and we are protected from that by RTNL mutex.
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> Acked-off-by: Stephen Hemminger <shemminger@vyatta.com>

It's "Acked-by" :-)

Applied, thanks!
