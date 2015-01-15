From: David Miller <davem@davemloft.net>
Subject: Re: [patch-net-next v2 3/3] net: ethernet: cpsw: don't requests
 IRQs we don't use
Date: Thu, 15 Jan 2015 18:16:15 -0500 (EST)
Message-ID: <20150115.181615.498992970722065060.davem@davemloft.net>
References: <1421254729-10602-3-git-send-email-balbi@ti.com>
	<54B770FC.6060003@ti.com>
	<20150115152053.GA16409@saruman>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, tony@atomide.com, linux-omap@vger.kernel.org,
	netdev@vger.kernel.org
To: balbi@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55672 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753057AbbAOXQR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 18:16:17 -0500
In-Reply-To: <20150115152053.GA16409@saruman>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felipe Balbi <balbi@ti.com>
Date: Thu, 15 Jan 2015 09:20:53 -0600

> On Thu, Jan 15, 2015 at 01:19:16PM +0530, Mugunthan V N wrote:
>> On Wednesday 14 January 2015 10:28 PM, Felipe Balbi wrote:
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
>> Instead of introducing dummy ISR in previous patch and then removing in
>> this patch, both can be squashed into a single patch.
> 
> sure they can. I decided to split to ease review and to make sure only
> one thing happens in a single patch.

Indeed, I agree that adding something as a placeholder that just gets
immediately removed should be avoided unless it is extremely difficult
to do so.
