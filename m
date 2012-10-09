From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pch_gbe: Fix build error by selecting all the possible
 dependencies.
Date: Tue, 09 Oct 2012 13:51:19 -0400 (EDT)
Message-ID: <20121009.135119.392429282974593732.davem@davemloft.net>
References: <20121006075954.GA29618@localhost>
	<1349775792-12573-1-git-send-email-haicheng.lee@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: haicheng.li@linux.intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, fengguang.wu@intel.com
To: haicheng.lee@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1349775792-12573-1-git-send-email-haicheng.lee@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haicheng Li <haicheng.lee@gmail.com>
Date: Tue,  9 Oct 2012 17:43:12 +0800

> Fengguang reported a kernel build failure as following:
> drivers/built-in.o: In function `pch_gbe_ioctl':
> pch_gbe_main.c:(.text+0x510370): undefined reference to `pch_ch_control_write'
> pch_gbe_main.c:(.text+0x510393): undefined reference to `pch_ch_control_write'
> pch_gbe_main.c:(.text+0x5103b3): undefined reference to `pch_ch_control_write'
> ...
> 
> It's a regression by commit da1586461. The root cause is that
> the CONFIG_PPS is not set there, consequently CONFIG_PTP_1588_CLOCK
> can not be set anyway, which finally causes ptp_pch and pch_gbe_main
> build failures.
> 
> As David prefers to use *select* to fix such module co-dependency issues,
> this patch explicitly selects all the possible dependencies of PCH_PTP.
> 
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Reviewed-by: David S. Miller <davem@davemloft.net>
> Signed-off-by: Haicheng Li <haicheng.lee@gmail.com>

Applied, thanks.
