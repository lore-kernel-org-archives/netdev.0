From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] igmp: spin_lock_bh in timer (Re: BUG: soft lockup detected on CPU#0!)
Date: Thu, 28 Dec 2006 13:56:26 +0100
Message-ID: <20061228125626.GA7826@ff.dom.local>
References: <45889C53.8000307@candelatech.com> <20061222071308.GA1791@ff.dom.local> <20061222074209.GA2148@ff.dom.local> <458BE61E.9030004@candelatech.com> <20061227082400.GA2070@ff.dom.local> <45929C4A.5000008@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:55316 "EHLO poczta.o2.pl"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754835AbWL1MzF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Dec 2006 07:55:05 -0500
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <45929C4A.5000008@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 27, 2006 at 08:16:10AM -0800, Ben Greear wrote:
...
> The system hangs and does not recover (well, a few processes
> continue on the other processor for a few minutes before they
> too deadlock...)
> 
> I am guessing this problem has been around for a while, but it
> is only triggered when interfaces are created, and probably only
> when UDP traffic is already running heavily on the system.  Most
> systems w/out virtual devices will not trigger this sort of
> race.

Considering your contribution into kernel,
many people here would like to help, I hope,
but these informations are probably not enough.

Maybe some more logs & dmesg? If it deadlocks
anyway, maybe adding panic() after dump_stack()
could tell something.

Jarek P.
