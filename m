From: David Miller <davem@davemloft.net>
Subject: Re: [rfc/rft][patch] should use scheduler sync hint in
 tcp_prequeue()?
Date: Thu, 04 Mar 2010 00:41:04 -0800 (PST)
Message-ID: <20100304.004104.24320938.davem@davemloft.net>
References: <1267529273.2964.111.camel@edumazet-laptop>
	<20100303.060529.195713861.davem@davemloft.net>
	<1267627610.6264.21.camel@marge.simson.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu
To: efault@gmx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1267627610.6264.21.camel@marge.simson.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mike Galbraith <efault@gmx.de>
Date: Wed, 03 Mar 2010 15:46:50 +0100

> On Wed, 2010-03-03 at 06:05 -0800, David Miller wrote:
> 
>> It definitely looks like an oversight to me and we should add
>> be using wake_up_interruptible_sync_poll() in tcp_prequeue()
>> as above.
>> 
>> Ingo?
> 
> Implied ack from network maintainer implies ship it to me.
> 
> net: add scheduler sync hint to tcp_prequeue().
> 
> Decreases the odds wakee will suffer from frequent cache misses.
> 
> Signed-off-by: Mike Galbraith <efault@gmx.de>

Applied.
