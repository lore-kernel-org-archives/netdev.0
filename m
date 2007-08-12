From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH] make atomic_t volatile on all architectures
Date: Sun, 12 Aug 2007 11:48:18 +0200
Message-ID: <1186912098.3852.11.camel@localhost>
References: <20070808230733.GA17270@shell.boston.redhat.com>
	 <alpine.LFD.0.999.0708082116060.25146@woody.linux-foundation.org>
	 <46BAC2BE.1090106@redhat.com> <46BB508B.7050601@redhat.com>
	 <alpine.LFD.0.999.0708091055080.25146@woody.linux-foundation.org>
	 <1186683646.9669.20.camel@localhost>
	 <a599bc5062d557db46496f0d7c7886b0@kernel.crashing.org>
	 <alpine.LFD.0.999.0708112305170.30176@woody.linux-foundation.org>
Reply-To: schwidefsky@de.ibm.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Segher Boessenkool <segher@kernel.crashing.org>,
	wjiang@resilience.com, wensong@linux-vs.org,
	heiko.carstens@de.ibm.com, linux-kernel@vger.kernel.org,
	ak@suse.de, cfriesen@nortel.com, netdev@vger.kernel.org,
	horms@verge.net.au, akpm@linux-foundation.org,
	Chuck Ebbert <cebbert@redhat.com>, davem@davemloft.net,
	zlynx@acm.org, Chris Snook <csnook@redhat.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:5568 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932397AbXHLJop (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Aug 2007 05:44:45 -0400
In-Reply-To: <alpine.LFD.0.999.0708112305170.30176@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2007-08-11 at 23:09 -0700, Linus Torvalds wrote: 
> Segher, how about you just accept that Linux uses gcc as per reality, and 
> that sometimes the reality is different from your expectations?
> 
> "+m" works. We use it. It's better than the alternatives. Pointing to 
> stale documentation doesn't change anything.

Well, perhaps on i386. I've seen some older versions of the s390 gcc die
with an ICE because I have used "+m" in some kernel inline assembly. I'm
happy to hear that this issue is fixed in recent gcc. Now I'll have to
find out if this is already true with gcc 3.x. The duplication "=m" and
"m" with the same constraint is rather annoying.

-- 
blue skies,
  Martin.

"Reality continues to ruin my life." - Calvin.



