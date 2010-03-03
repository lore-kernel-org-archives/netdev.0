From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] bridge: depends on INET
Date: Wed, 03 Mar 2010 01:23:59 -0800 (PST)
Message-ID: <20100303.012359.66790294.davem@davemloft.net>
References: <20100302180915.1388d3f3.sfr@canb.auug.org.au>
	<4B8D4607.8070603@xenotime.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, shemminger@linux-foundation.org,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: rdunlap@xenotime.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B8D4607.8070603@xenotime.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@xenotime.net>
Date: Tue, 02 Mar 2010 09:08:23 -0800

> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> br_multicast calls ip_send_check(), so it should depend on INET.
> 
> built-in:
> br_multicast.c:(.text+0x88cf4): undefined reference to `ip_send_check'
> 
> or modular:
> ERROR: "ip_send_check" [net/bridge/bridge.ko] undefined!
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

Applied, but I almost lost this patch.

You need to CC: netdev on all networking patches so that it
gets properly tracked in patchwork and therefore does not get
lost.

Thanks.
