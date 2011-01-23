From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: ipv6 steaming pile of poo...
Date: Mon, 24 Jan 2011 09:20:43 +1000
Message-ID: <20110124092043.49b7d34a@s6510>
References: <20110123.123754.246545770.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35334 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752194Ab1AWXUt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Jan 2011 18:20:49 -0500
In-Reply-To: <20110123.123754.246545770.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 23 Jan 2011 12:37:54 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> 
> Thanks to the fact that I let a change causing known regressions live
> in the tree for almost a year (don't worry I've learned my lesson):
> 
> From dc2b99f71ef477a31020511876ab4403fb7c4420 Mon Sep 17 00:00:00 2001
> From: stephen hemminger <shemminger@vyatta.com>
> Date: Mon, 8 Feb 2010 19:48:05 +0000
> Subject: [PATCH] IPv6: keep permanent addresses on admin down
> 
> We have over a year of follow-up changes to revert if we want to
> get rid of this turd.
> 
> This means getting rid of all the changes that tried to fix bugs in
> the new ipv6 semantics made by Lorenzo Colitti, and the hlist
> conversions, and all changes dependent upon those.
> 
> But no matter, this has to be done and I don't care if we lost lots
> of cleanups and other work as a result of doing this, it just has to
> be done.
> 
> And this is _why_ we must revert changes causing known regressions
> as soon as they are discovered, not months or a year later.  Because
> after that much time, undoing the damage becomes that much harder.
> 
> So if you folks wonder what I'm working on the next couple of days,
> this is it.
> --

Please post the full set of diffs, to allow for putting the bug fixes
back.
