From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH  kernel 2.6.35-rc3-git7] axnet_cs: use
 spin_lock_irqsave in ax_interrupt
Date: Sun, 11 Jul 2010 03:46:28 +0100
Message-ID: <1278816388.6139.10.camel@localhost>
References: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
	 <20090419084444.4ee7ddee.ken_kawasaki@spring.nifty.jp>
	 <20090426162929.3d036f26.ken_kawasaki@spring.nifty.jp>
	 <20090913172257.6c1976ec.ken_kawasaki@spring.nifty.jp>
	 <20091004073257.52a6624b.ken_kawasaki@spring.nifty.jp>
	 <20091221205849.dae4e929.ken_kawasaki@spring.nifty.jp>
	 <20091223171004.77316fa5.ken_kawasaki@spring.nifty.jp>
	 <20100123065625.db751a12.ken_kawasaki@spring.nifty.jp>
	 <20100228083420.9ca8e285.ken_kawasaki@spring.nifty.jp>
	 <20100612191728.2d272cc1.ken_kawasaki@spring.nifty.jp>
	 <20100620102427.77d2c7d3.ken_kawasaki@spring.nifty.jp>
	 <20100706202243.95319ab4.ken_kawasaki@spring.nifty.jp>
	 <20100710201813.a3e5c79c.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:40481 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753195Ab0GKCqf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jul 2010 22:46:35 -0400
In-Reply-To: <20100710201813.a3e5c79c.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-07-10 at 20:18 +0900, Ken Kawasaki wrote:
> axnet_cs:
>     use spin_lock_irqsave instead of spin_lock in ax_interrupt
[...]

I assume this is because it's now called from ei_watchdog() and not only
from interrupt context.  Perhaps you should explain that in the commit
message.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

