From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Network hangs with 2.6.30.5
Date: Fri, 2 Oct 2009 11:11:55 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.0910021104130.13543@wel-95.cs.helsinki.fi>
References: <pan.2009.09.03.19.55.37.672875@googlemail.com> <20090907072143.GA5966@ff.dom.local> <20091001.154913.88345178.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, holger.hoffstaette@googlemail.com,
	Netdev <netdev@vger.kernel.org>, eric.dumazet@gmail.com,
	Evgeniy Polyakov <zbr@ioremap.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:59591 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754145AbZJBILw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 04:11:52 -0400
In-Reply-To: <20091001.154913.88345178.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 1 Oct 2009, David Miller wrote:

> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Mon, 7 Sep 2009 07:21:43 +0000
> 
> > While Eric is analyzing your data, I guess you could try reverting
> > some stuff around this tcp_tw_recycle, and my tcp ignorance would
> > point these commits for the beginning:
> > 
> > http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.30.y.git;a=commitdiff;h=fc1ad92dfc4e363a055053746552cdb445ba5c57
> > http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.30.y.git;a=commitdiff;h=c887e6d2d9aee56ee7c9f2af4cec3a5efdcc4c72
> 
> Ilpo's cleanup (the second commit listed) looks most likely to
> be a possibility.
> 
> But I surely cannot find any bugs in it, even after studying it
> a few times.
> 
> Ilpo could you audit it one more time for us just in case?

Argh, not that one ...the jungle of negations. But I'll try to go it 
through once more but I tell you I did go through those negations multiple 
times already before submitting it :-).

> I also looked through all the TCP commits in 2.6.29 to 2.6.30
> and I could not find anything else that might cause stalls with
> time-wait recycled connections.

What about the more than 64k connections change a9d8f9110d7e953c2f2 (or 
its fixes), it might be another possibility? ...It certainly does 
something related to reuse and happens to be in the correct time frame... 
(I've added Evgeniy).

-- 
 i.
