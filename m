From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix ZOMBIE state bug in PPPOE driver
Date: Wed, 19 Sep 2012 16:26:22 -0400 (EDT)
Message-ID: <20120919.162622.1418427955928784832.davem@davemloft.net>
References: <CANEcBPSEamgOiGqNUSwB+hYCo1k2OTXDA=qsrw0Co8_F7treWw@mail.gmail.com>
	<CANEcBPQnsV26UkyGxms0vKM9wK1NxfKjN4Z0qGipQtV4UPZgGA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: stid.smth@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANEcBPQnsV26UkyGxms0vKM9wK1NxfKjN4Z0qGipQtV4UPZgGA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xiaodong Xu <stid.smth@gmail.com>
Date: Sun, 16 Sep 2012 10:30:53 +0800

> Hi All,
> 
> I found a bug in kernel PPPOE driver.
> When PPPOE is running over a virtual ethernet interface (e.g., a
> bonding interface) and the user tries to delete the interface in case
> the PPPOE state is ZOMBIE, the kernel will loop infinitely while
> unregistering net_device for the reference count is not reset to zero
> which should be done by dev_put().
> 
> The following patch could fix this issue:
> 
> $ git diff

Please read Documentation/SubmittingPatches in the kernel source tree
to learn how to properly submit a patch.

In particular your patch was missing a proper signoff and your Subject
line is incorrectly specified.

Thanks.
