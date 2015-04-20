From: Petr Mladek <pmladek@suse.cz>
Subject: Re: [PATCH 01/16] printk: guard the amount written per line by
 devkmsg_read()
Date: Mon, 20 Apr 2015 14:33:49 +0200
Message-ID: <20150420123348.GG4368@pathway.suse.cz>
References: <1429225433-11946-1-git-send-email-tj@kernel.org>
 <1429225433-11946-2-git-send-email-tj@kernel.org>
 <20150420121136.GE4368@pathway.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Kay Sievers <kay@vrfy.org>
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150420121136.GE4368@pathway.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon 2015-04-20 14:11:36, Petr Mladek wrote:
> On Thu 2015-04-16 19:03:38, Tejun Heo wrote:
> > devkmsg_read() uses 8k buffer and assumes that the formatted output
> > message won't overrun which seems safe given LOG_LINE_MAX, the current
> > use of dict and the escaping method being used; however, we're
> > planning to use devkmsg formatting wider and accounting for the buffer
> > size properly isn't that complicated.
> > 
> > This patch defines CONSOLE_EXT_LOG_MAX as 8192 and updates
> > devkmsg_read() so that it limits output accordingly.
> > 
> > Signed-off-by: Tejun Heo <tj@kernel.org>
> 
> Reviewed-by: Petr Mladek <pmladek@suse.cz>
> 
> It is just a refactoring and does not modify the current behavior.

Ah, to make it clear. It did not modify the behavior except for
adding the check for potential buffer overflow.

Best Regards,
Petr
