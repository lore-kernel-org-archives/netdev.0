From: Flavio Leitner <fbl@sysclose.org>
Subject: Re: [v5 Patch 1/3] netpoll: add generic support for bridge and
 bonding devices
Date: Thu, 27 May 2010 18:25:23 -0300
Message-ID: <20100527212523.GB2345@sysclose.org>
References: <20100505081514.5157.83783.sendpatchset@localhost.localdomain>
 <20100527180545.GA2345@sysclose.org>
 <20100527.133559.193700421.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: amwang@redhat.com, linux-kernel@vger.kernel.org, mpm@selenic.com,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	gospo@redhat.com, nhorman@tuxdriver.com, jmoyer@redhat.com,
	shemminger@linux-foundation.org,
	bonding-devel@lists.sourceforge.net, fubar@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100527.133559.193700421.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 27, 2010 at 01:35:59PM -0700, David Miller wrote:
> From: Flavio Leitner <fbl@sysclose.org>
> Date: Thu, 27 May 2010 15:05:45 -0300
> 
> > I did the following patch to discard the packet if it was IN_NETPOLL
> > and the read_lock() fails, so I could go ahead testing it:
> 
> This is disgusting, let's just disallow console output from such
> locations.  Defer them to a workqueue if their output is so critical.

I did that patch just to see the backtrace in the serial console
and to keep testing it. It's not a solution at all.

Just to be clear, the second problem isn't related to that patch
and the console message is already in a workqueue.

-- 
Flavio
