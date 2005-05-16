From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: patch tulip-natsemi-dp83840a-phy-fix.patch added to -mm tree
Date: Sun, 15 May 2005 23:08:43 -0600
Message-ID: <20050516050843.GA20107@colo.lackof.org>
References: <200505101955.j4AJtX9x032464@shell0.pdx.osdl.net> <42881C58.40001@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, T-Bone@parisc-linux.org, grundler@parisc-linux.org,
	varenet@parisc-linux.org,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Netdev <netdev@oss.sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261277AbVEPFFr@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <42881C58.40001@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 16, 2005 at 12:06:48AM -0400, Jeff Garzik wrote:
> Note that while the patch creates the correct behavior, the delays above 
> occur inside spin_lock_irqsave() and/or timer context.

Yes. Agreed.  So what?

If tulip phy init code is hit so often *and* seeing the worst case
2ms delay that it's a problem, the delay doesn't matter.
Something else is fundamentally wrong.

Fixing code that doesn't comply with published specs and has
been proven to not work on at least 3 archs seems a bit more
important than an occasional < 1ms (normal case) delay.

> I have been to get HP to fix this patch's delay problem for -years-.

I was "encouraged" to rewrite the tulip phy init sequence in 2002
to use schedule_timeout() and heard a claim it would be trivial.

I looked into it and concluded it was NOT trivial.
I approached Jeff at OLS2002 (or 2003) and explained why I thought it
was NOT trivial.  Didn't get a response that resolved any of the
concerns I raised. I'd be willing to take another look at fresh
ideas once all of the tulip patches I have ouststanding go in.

If the original suggestion really were trivial, we wouldn't be having
this conversation now.  Some high school student would have taken care
of it by now, right?

thanks,
grant
