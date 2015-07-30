From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH] printk: Warn about dropped messages also on extended
 consoles
Date: Thu, 30 Jul 2015 17:02:09 +0200
Message-ID: <20150730150209.GM2673@pathway.suse.cz>
References: <1438255732-31326-1-git-send-email-pmladek@suse.com>
 <20150730133901.GC3504@mtj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150730133901.GC3504@mtj.duckdns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu 2015-07-30 09:39:01, Tejun Heo wrote:
> Hello,
> 
> On Thu, Jul 30, 2015 at 01:28:52PM +0200, Petr Mladek wrote:
> > The commit #6fe29354befe4c ("printk: implement support for extended console
> > drivers") added an extra buffer to format messages for extended consoles.
> > We need to put there also the warning about dropped messages, so it appears
> > on these consoles.
> 
> I don't get it.  Extended messages are all stamped with sequence
> number and the gap in sequence number is a clear sign of missing
> messages.

Grr, I misconfigured netconsole and did not see the extended
information. You are right, the patch is not needed.

Best Regards,
Petr
