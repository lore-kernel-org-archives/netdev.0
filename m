From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 5/5 v2] netfilter: Fix format string of nfnetlink_log
 proc file
Date: Thu, 9 Apr 2015 18:43:42 -0400
Message-ID: <20150409184342.4c3737a5@gandalf.local.home>
References: <1428616637-21690-1-git-send-email-richard@nod.at>
	<1428616637-21690-5-git-send-email-richard@nod.at>
	<1428619177.5413.15.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Richard Weinberger <richard@nod.at>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, coreteam@netfilter.org,
	netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
	sameo@linux.intel.com, aloisio.almeida@openbossa.org,
	lauro.venancio@openbossa.org, davem@davemloft.net,
	kadlec@blackhole.kfki.hu, kaber@trash.net, pablo@netfilter.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1428619177.5413.15.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 09 Apr 2015 15:39:37 -0700
Joe Perches <joe@perches.com> wrote:

> And Steven,
> 
> commit e71456ae9871
> ("netfilter: Remove checks of seq_printf() return values")
> mistakenly converted this to use seq_has_overflowed()
> 
> Ideally all seq_show functions would be converted from
> 
> int foo_seq_show(...)
> {
> 	seq_printf(s, ...);
> 	return seq_has_overflowed(s);
> }
> 
> to
> 
> int foo_seq_show(...)
> {
> 	seq_printf(s, ...);
> 	return 0;
> }
> 
> I made that mistake in a patch and corrected it later.
> 
> Here's a suggested -next patch:
> 
> Perhaps it shouldn't be submitted now as it may conflict
> with what Richard might submit if he propses an equivalent
> patch to above for -next.
> 
> There is an appropriate use of return seq_has_overflowed in: 
> 
> net/netfilter/xt_hashlimit.c:825:       return seq_has_overflowed(s);
> 
> That's not a seq_show function, it's a helper for one.

I have other things to work on, so feel free to fix it up among
yourselves.

-- Steve
