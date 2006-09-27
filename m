From: David Miller <davem@davemloft.net>
Subject: Re: tc related lockdep warning.
Date: Wed, 27 Sep 2006 16:53:04 -0700 (PDT)
Message-ID: <20060927.165304.116354998.davem@davemloft.net>
References: <45195219.7050105@trash.net>
	<20060926212034.GA3134@redhat.com>
	<451A6968.2090607@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, hadi@cyberus.ca, jarkao2@o2.pl,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:8882
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1031258AbWI0XxF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 19:53:05 -0400
To: kaber@trash.net
In-Reply-To: <451A6968.2090607@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 27 Sep 2006 14:07:04 +0200

> Dave Jones wrote:
> > With this patch, I get no lockdep warnings, but the machine locks up completely.
> > I hooked up a serial console, and found this..
> > 
> > 
> > u32 classifier
> >     Performance counters on
> >     input device check on 
> >     Actions configured 
> > BUG: warning at net/sched/sch_htb.c:395/htb_safe_rb_erase()
> > 
> > Call Trace:
> >  [<ffffffff8026f79b>] show_trace+0xae/0x336
> >  [<ffffffff8026fa38>] dump_stack+0x15/0x17
> >  [<ffffffff8860a171>] :sch_htb:htb_safe_rb_erase+0x3b/0x55
> 
> I found the reason for this, it was an unrelated bug. I've attached
> the latest version of the locking fixes and the fix for the HTB bug.
> Can you please try again?

Although the HTB bug is post-2.6.18, the other issue has been
around for a long time.

Thus I'll need to submit the second patch to -stable, but I want
it to cook in Linus's tree for a few days before I do that.

Thanks.
