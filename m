From: David Miller <davem@davemloft.net>
Subject: Re: [net:master 1/9] pch_gbe_main.c:(.text+0x510370): undefined
 reference to `pch_ch_control_write'
Date: Sat, 06 Oct 2012 17:17:48 -0400 (EDT)
Message-ID: <20121006.171748.734171045678392820.davem@davemloft.net>
References: <50703B1B.2040705@linux.intel.com>
	<20121006.102132.1497404004255213029.davem@davemloft.net>
	<50706885.1030908@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: haicheng.li@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50706885.1030908@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haicheng Li <haicheng.li@linux.intel.com>
Date: Sun, 07 Oct 2012 01:21:09 +0800

> Take IXGBE_PTP as example, it explicitly selects PPS, and also depends
> on EXPERIMENTAL:
> config IXGBE_PTP
>         bool "PTP Clock Support"
>         default n
>         depends on IXGBE && EXPERIMENTAL
>         select PPS
>         select PTP_1588_CLOCK
> 
> So if you stick to use "select" as the convention of such build issue
> fixing, fengguang's build failure would be fixed by:
> 	+ depends on EXPERIMENTAL
> 	+ select PPS
> 	+ select PTP_1588_CLOCK
> 
> would you prefer this way?

Yes, I would.

Thanks.
