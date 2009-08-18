From: DDD <Dongdong.deng@windriver.com>
Subject: Re: [PATCH] drivers/net: fixed drivers that support netpoll use
	ndo_start_xmit()
Date: Tue, 18 Aug 2009 13:59:26 +0800
Message-ID: <1250575166.29401.183.camel@dengdd-desktop>
References: <1250226751.29401.82.camel@dengdd-desktop>
	 <1250264019.3807.1301.camel@calx>
	 <20090814.163232.234331420.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Bruce.Ashfield@windriver.com, jason.wessel@windriver.com
To: David Miller <davem@davemloft.net>, mpm@selenic.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751819AbZHRFrW@vger.kernel.org>
In-Reply-To: <20090814.163232.234331420.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2009-08-14 at 16:32 -0700, David Miller wrote:
> From: Matt Mackall <mpm@selenic.com>
> Date: Fri, 14 Aug 2009 10:33:39 -0500
> 
> > On Fri, 2009-08-14 at 13:12 +0800, DDD wrote:
> >> The NETPOLL API requires that interrupts remain disabled in
> >> netpoll_send_skb(). The use of spin_lock_irq() and
> spin_unlock_irq()
> >> in the NETPOLL API callbacks causes the interrupts to get enabled
> and
> >> can lead to kernel instability.
> >> 
> >> The solution is to use spin_lock_irqsave() and
> spin_unlock_restore()
> >> to prevent the irqs from getting enabled while in
> netpoll_send_skb().
> ...
> >> Signed-off-by: Dongdong Deng <dongdong.deng@windriver.com>
> >> Signed-off-by: Jason Wessel <jason.wessel@windriver.com>
> >> Acked-by: Bruce Ashfield <bruce.ashfield@windriver.com>
> > 
> > Acked-by: Matt Mackall <mpm@selenic.com>
> 
> Applied, thanks everyone.
Thanks. :-)

> 
> > Perhaps we should also have a WARN_ONCE if start_xmit returns with
> > interrupts enabled?
> 
> Probably a good idea.
I think it is a good idea too, thanks for your suggestion, Matt.
I will do a tiny patch for it shortly.


Dongdong
