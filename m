From: David Miller <davem@davemloft.net>
Subject: Re: [patch-net-next v3 2/2] net: ethernet: cpsw: don't requests
 IRQs we don't use
Date: Mon, 19 Jan 2015 12:38:31 -0500 (EST)
Message-ID: <20150119.123831.1656325571902467083.davem@davemloft.net>
References: <1421424672-19323-2-git-send-email-balbi@ti.com>
	<20150118.010750.480741880077015933.davem@davemloft.net>
	<20150119144017.GB20386@saruman>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tony@atomide.com, linux-omap@vger.kernel.org, mugunthanvnm@ti.com,
	netdev@vger.kernel.org
To: balbi@ti.com
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <20150119144017.GB20386@saruman>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Felipe Balbi <balbi@ti.com>
Date: Mon, 19 Jan 2015 08:40:17 -0600

> On Sun, Jan 18, 2015 at 01:07:50AM -0500, David Miller wrote:
>> From: Felipe Balbi <balbi@ti.com>
>> Date: Fri, 16 Jan 2015 10:11:12 -0600
>> 
>> > CPSW never uses RX_THRESHOLD or MISC interrupts. In
>> > fact, they are always kept masked in their appropriate
>> > IRQ Enable register.
>> > 
>> > Instead of allocating an IRQ that never fires, it's best
>> > to remove that code altogether and let future patches
>> > implement it if anybody needs those.
>> > 
>> > Signed-off-by: Felipe Balbi <balbi@ti.com>
>> 
>> Applied.
> 
> looks like randconfig caught a build break. Do you want an incremental
> patch or this patch again with the fix in it ?

Always incremental patches.
