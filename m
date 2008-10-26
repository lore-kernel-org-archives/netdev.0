From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Sun, 26 Oct 2008 13:05:55 +0300
Message-ID: <20081026100555.GA26033@ioremap.net>
References: <20081024.221653.23695396.davem@davemloft.net> <1224914333.3822.18.camel@marge.simson.net> <1224917623.4929.15.camel@marge.simson.net> <20081025.002420.82739316.davem@davemloft.net> <Pine.LNX.4.64.0810260055070.22126@twin.jikos.cz> <1225010790.8566.22.camel@marge.simson.net> <1225011648.27415.4.camel@twins> <20081026021153.47878580.akpm@linux-foundation.org> <20081026092722.GA24799@ioremap.net> <20081026023439.c6cf4e94.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Mike Galbraith <efault@gmx.de>, Jiri Kosina <jkosina@suse.cz>,
	David Miller <davem@davemloft.net>, rjw@sisk.pl,
	Ingo Molnar <mingo@elte.hu>, s0mbre@tservice.net.ru,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from genesysrack.ru ([195.178.208.66]:33024 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751361AbYJZKF5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Oct 2008 06:05:57 -0400
Content-Disposition: inline
In-Reply-To: <20081026023439.c6cf4e94.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew.

On Sun, Oct 26, 2008 at 02:34:39AM -0700, Andrew Morton (akpm@linux-foundation.org) wrote:
> Not necessarily.  There are times when we have made changes which we
> knew full well reduced dbench's throughput, because we believed them to
> be of overall benefit.  I referred to one of them above.

I suppose, there were words about dbench is not a real-life test, so if
it will suddenly suck, no one will care. Sigh, theorists...
I'm not surprised there were no changes when I reported hrtimers to be
the main guilty factor in my setup for dbench tests, and only when David
showed that they also killed his sparks via wake_up(), something was
done. Now this regression even dissapeared from the list.
Good direction, we should always follow this.

As a side note, is hrtimer subsystem also used for BH backend? I have
not yet analyzed data about vanilla kernels only being able to accept
clients at 20-30k accepts per second, while some other magical tree
(not vanilla) around 2.6.18 was able to that with 50k accepts per
second. There are lots of CPUs, ram, bandwidth, which are effectively
unused even behind linux load balancer...

-- 
	Evgeniy Polyakov
