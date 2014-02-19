From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH -next] net: tcp: add mib counters to track zero window transitions
Date: Wed, 19 Feb 2014 20:32:13 +0100
Message-ID: <20140219193213.GD1179@order.stressinduktion.org>
References: <1392674268-26005-1-git-send-email-fw@strlen.de> <20140219.131708.562226572566677127.davem@davemloft.net> <1392835787.18849.11.camel@edumazet-glaptop2.roam.corp.google.com> <20140219185949.GA1179@order.stressinduktion.org> <20140219191831.GA7119@breakpoint.cc> <20140219193038.GC1179@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Florian Westphal <fw@strlen.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:39064 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754542AbaBSTcO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 14:32:14 -0500
Content-Disposition: inline
In-Reply-To: <20140219193038.GC1179@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry...

On Wed, Feb 19, 2014 at 08:30:38PM +0100, Hannes Frederic Sowa wrote:
> NET_STATS only use 32 bit counter and thus need not be protected with a
> seqlock on 32 bit platforms. As such, it does not matter, but e.g. the IP
> counter are prone to deadlocks if used with wrong postfix because of 64 bit
> counter thus protected by seqlock.
> 
> A pitty that the _STATS_BH postfixes have the opposite meaning of the bottom

	s/bottom$/locking/

> _bh postfixes.
> 
> Basically always safe is _STATS and if we are sure we can omit the bh disable
> call because we only call the function from bh, we can use _STATS_BH calls.

Should read mails again before sending. ;)
