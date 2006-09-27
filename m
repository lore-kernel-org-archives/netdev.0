From: Dave Jones <davej@redhat.com>
Subject: Re: tc related lockdep warning.
Date: Wed, 27 Sep 2006 13:33:18 -0400
Message-ID: <20060927173318.GA12312@redhat.com>
References: <20060925124352.GA1592@ff.dom.local> <1159188473.5301.68.camel@jzny2> <4517D9A6.70307@trash.net> <45195219.7050105@trash.net> <20060926212034.GA3134@redhat.com> <451A6968.2090607@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, Jarek Poplawski <jarkao2@o2.pl>,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:3979 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1030478AbWI0Rea (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 13:34:30 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <451A6968.2090607@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 27, 2006 at 02:07:04PM +0200, Patrick McHardy wrote:
 > Dave Jones wrote:
 > > 
 > > Call Trace:
 > >  [<ffffffff8026f79b>] show_trace+0xae/0x336
 > >  [<ffffffff8026fa38>] dump_stack+0x15/0x17
 > >  [<ffffffff8860a171>] :sch_htb:htb_safe_rb_erase+0x3b/0x55
 > 
 > I found the reason for this, it was an unrelated bug. I've attached
 > the latest version of the locking fixes and the fix for the HTB bug.
 > Can you please try again?

Yep, that does the trick for me.

Good job.

	Dave
