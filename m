From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH] make atomic_t volatile on all architectures
Date: Sun, 12 Aug 2007 18:30:32 +0200
Message-ID: <74868f39491f8691afc5540f72679129@kernel.crashing.org>
References: <20070808230733.GA17270@shell.boston.redhat.com> <alpine.LFD.0.999.0708082116060.25146@woody.linux-foundation.org> <46BAC2BE.1090106@redhat.com> <46BB508B.7050601@redhat.com> <alpine.LFD.0.999.0708091055080.25146@woody.linux-foundation.org> <1186683646.9669.20.camel@localhost> <a599bc5062d557db46496f0d7c7886b0@kernel.crashing.org> <alpine.LFD.0.999.0708112305170.30176@woody.linux-foundation.org> <1186912098.3852.11.camel@localhost>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wjiang@resilience.com,
	Linus Torvalds <torvalds@linux-foundation.org>,
	wensong@linux-vs.org, heiko.carstens@de.ibm.com,
	linux-kernel@vger.kernel.org, ak@suse.de, cfriesen@nortel.com,
	netdev@vger.kernel.org, horms@verge.net.au,
	akpm@linux-foundation.org, Chuck Ebbert <cebbert@redhat.com>,
	davem@davemloft.net, zlynx@acm.org, Chris Snook <csnook@redhat.com>
To: schwidefsky@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:50408 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753884AbXHLQgh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Aug 2007 12:36:37 -0400
In-Reply-To: <1186912098.3852.11.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> "+m" works. We use it. It's better than the alternatives. Pointing to
>> stale documentation doesn't change anything.
>
> Well, perhaps on i386. I've seen some older versions of the s390 gcc 
> die
> with an ICE because I have used "+m" in some kernel inline assembly. 
> I'm
> happy to hear that this issue is fixed in recent gcc. Now I'll have to
> find out if this is already true with gcc 3.x.

It was fixed (that is, "+m" is translated into a separate read
and write by GCC itself) in GCC-4.0.0, I just learnt.

> The duplication "=m" and "m" with the same constraint is rather 
> annoying.

Yeah.  Compiler errors are more annoying though I dare say ;-)


Segher

