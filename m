From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [net] smc91x: let smc91x work well under netpoll
Date: Sun, 23 Aug 2009 22:59:12 -0700 (PDT)
Message-ID: <20090823.225912.87554943.davem@davemloft.net>
References: <1250862005.24178.28.camel@dengdd-desktop>
	<alpine.LFD.2.00.0908211304000.6044@xanadu.home>
	<1251085351.6588.21.camel@dengdd-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nico@cam.org, mpm@selenic.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jason.wessel@windriver.com
To: Dongdong.deng@windriver.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751580AbZHXF7B@vger.kernel.org>
In-Reply-To: <1251085351.6588.21.camel@dengdd-desktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: DDD <Dongdong.deng@windriver.com>
Date: Mon, 24 Aug 2009 11:42:31 +0800

> The NETPOLL requires that interrupts remain disabled in its callbacks.
> 
> Using *_irq_save()/irq_restore() to replace *_irq_disable()/irq_enable()
> functions in NETPOLL's callbacks of smc91x, so that it doesn't enable
> interrupts when already disabled, and kgdboe/netconsole would work
> properly over smc91x.
> 
> Signed-off-by: Dongdong Deng <dongdong.deng@windriver.com>
> Acked-by: Nicolas Pitre <nico@cam.org>

Applied, thanks.
