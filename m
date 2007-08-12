From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] make atomic_t volatile on all architectures
Date: Sat, 11 Aug 2007 23:09:56 -0700 (PDT)
Message-ID: <alpine.LFD.0.999.0708112305170.30176@woody.linux-foundation.org>
References: <20070808230733.GA17270@shell.boston.redhat.com>
 <alpine.LFD.0.999.0708082116060.25146@woody.linux-foundation.org>
 <46BAC2BE.1090106@redhat.com> <46BB508B.7050601@redhat.com>
 <alpine.LFD.0.999.0708091055080.25146@woody.linux-foundation.org>
 <1186683646.9669.20.camel@localhost>
 <a599bc5062d557db46496f0d7c7886b0@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: schwidefsky@de.ibm.com, wjiang@resilience.com,
	wensong@linux-vs.org, heiko.carstens@de.ibm.com,
	linux-kernel@vger.kernel.org, ak@suse.de, cfriesen@nortel.com,
	netdev@vger.kernel.org, horms@verge.net.au,
	akpm@linux-foundation.org, Chuck Ebbert <cebbert@redhat.com>,
	davem@davemloft.net, zlynx@acm.org, Chris Snook <csnook@redhat.com>
To: Segher Boessenkool <segher@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:52542 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752522AbXHLGKr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Aug 2007 02:10:47 -0400
In-Reply-To: <a599bc5062d557db46496f0d7c7886b0@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Sun, 12 Aug 2007, Segher Boessenkool wrote:
>
> Note that last line.

Segher, how about you just accept that Linux uses gcc as per reality, and 
that sometimes the reality is different from your expectations?

"+m" works. We use it. It's better than the alternatives. Pointing to 
stale documentation doesn't change anything.

The same is true of accesses through a volatile pointer. The kernel has 
done that for a *loong* time (all MMIO IO is done that way), and it's 
totally pointless to say that "volatile" isn't guaranteed to do what it 
does. It works, and quite frankly, if it didn't work, it would be a gcc 
BUG.

And again, this is not a "C standard" issue. It's a "sane implementation" 
issue. Linux expects the compiler to be sane. If it isn't, that's not our 
problem. gcc *is* sane, and I don't see why you constantly act as if it 
wasn't.

		Linus
