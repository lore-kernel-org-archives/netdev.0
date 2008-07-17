From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [bug, netconsole, SLUB] BUG skbuff_head_cache: Poison
	overwritten
Date: Fri, 18 Jul 2008 00:43:39 +0200
Message-ID: <20080717224338.GA461@elte.hu>
References: <20080717214222.GA29449@elte.hu> <20080717.144504.96425101.davem@davemloft.net> <20080717220600.GA1701@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	penberg@cs.helsinki.fi, vegard.nossum@gmail.com, rjw@sisk.pl
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:39955 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754513AbYGQWoH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2008 18:44:07 -0400
Content-Disposition: inline
In-Reply-To: <20080717220600.GA1701@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Ingo Molnar <mingo@elte.hu> wrote:

> Just re-tried it, the bug is reliably repeatable. Will try a bisection 
> run.

hm, but it was not reproducible on the third and fourth attempt :-( I 
tried hard to provoke it by generating artificial parallel network and 
netconsole output - but it didnt want to trigger. Heisenbug ...

Maybe the debug output gives someone an idea about the nature of the 
bug?

	Ingo
