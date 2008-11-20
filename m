From: Willy Tarreau <w@1wt.eu>
Subject: Re: WARNING: at net/sched/sch_generic.c:219 dev_watchdog+0xfe/0x17e() with tg3 network
Date: Thu, 20 Nov 2008 06:37:47 +0100
Message-ID: <20081120053746.GB15168@1wt.eu>
References: <491954E1.2050002@gmail.com> <1226403067.7685.1598.camel@twins> <491E49AA.60407@gmail.com> <20081118065006.GC24654@1wt.eu> <20081120031101.GD26448@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roger Heflin <rogerheflin@gmail.com>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1307 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752623AbYKTFh4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2008 00:37:56 -0500
Content-Disposition: inline
In-Reply-To: <20081120031101.GD26448@xw6200.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Matt,

On Wed, Nov 19, 2008 at 07:11:01PM -0800, Matt Carlson wrote:
> > My tg3 is just PCI-based, no PCIe in this beast. I can send more
> > info when I turn it on. I don't think that the tg3 driver changes
> > often, so most likely digging through the changes between 2.6.25
> > and 2.6.27 should not take much time. I just don't know if I can
> > reliably reproduce the issue right now.
> 
> Willy, this problem description sounds a little different than the
> original report.  There was a bug where the driver would wait 2.5
> seconds for a firmware event that would never get serviced.  That
> fix has already landed in the 2.6.27 tree though.
> 
> I glanced over the changes between 2.6.25 and 2.6.27.6.  There are quite
> a few changes related to phylib support for an upcoming device, but not
> so many changes that affect older devices.  What device are you using?

I think it's a 5704, but I will check this this morning when I'm at
work. I also want to try to reliably reproduce the problem. After
that, I see only 29 patches which differ from the two kernels, it
should be pretty easy to spot the culprit.

If you think it's a different bug than original report (though I
really thought it was the same), I'll post my findings in a separate
thread not to mix investigations.

Thanks,
Willy

