From: David Miller <davem@davemloft.net>
Subject: Re: [patch 07/16] atm: firestream: Use del_timer_sync() in
 teardown path
Date: Tue, 25 Mar 2014 21:06:25 -0400 (EDT)
Message-ID: <20140325.210625.2118615732170549372.davem@davemloft.net>
References: <20140323150557.288925975@linutronix.de>
	<20140323150753.325835408@linutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Julia.Lawall@lip6.fr,
	akpm@linux-foundation.org, chas@cmf.nrl.navy.mil,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: tglx@linutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140323150753.325835408@linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Gleixner <tglx@linutronix.de>
Date: Sun, 23 Mar 2014 15:09:28 -0000

> The device is about to vanish. So we need to make sure that the timer
> is completely stopped and the callback is not running on another CPU.
> 
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>

Applied.
