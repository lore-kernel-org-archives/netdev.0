From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Prevent netpoll hanging when link is down
Date: Mon, 11 Oct 2004 18:43:15 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041011164315.GH26350@wotan.suse.de>
References: <20041007224422.1c1bea95@jack.colino.net> <20041007214505.GB31558@wotan.suse.de> <20041008090610.70d7e183@pirandello> <20041008220001.GE31237@waste.org> <20041008151839.01823e0c.akpm@osdl.org> <20041010205928.6e54df7e.davem@davemloft.net> <20041011154000.GB26350@wotan.suse.de> <20041011162224.GL31237@waste.org> <20041011163226.GG26350@wotan.suse.de> <20041011163601.GM31237@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, "David S. Miller" <davem@davemloft.net>,
        Andrew Morton <akpm@osdl.org>, colin@colino.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matt Mackall <mpm@selenic.com>
Content-Disposition: inline
In-Reply-To: <20041011163601.GM31237@waste.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> It's not recursion on printk that's a problem, it's recursion on
> ->poll() and attempting to take whatever internal driver locks.

There is no recursion on poll because printk will never call into
the low level console driver when the console sem is already taken.

-Andi

P.S.: I made the same mistake long ago, but akpm set me straight.
