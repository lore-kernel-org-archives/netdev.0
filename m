From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH 24/24] document volatile atomic_read() behavior
Date: Thu, 9 Aug 2007 17:59:29 +0200
Message-ID: <8f6bb8a9e4f2819a161d732bdb6c70c0@kernel.crashing.org>
References: <20070809142430.GA19817@shell.boston.redhat.com>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wjiang@resilience.com, wensong@linux-vs.org,
	heiko.carstens@de.ibm.com, linux-kernel@vger.kernel.org,
	ak@suse.de, cfriesen@nortel.com, netdev@vger.kernel.org,
	horms@verge.net.au, akpm@linux-foundation.org,
	linux-arch@vger.kernel.org, torvalds@linux-foundation.org,
	schwidefsky@de.ibm.com, davem@davemloft.net, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com
To: Chris Snook <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:39606 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S940023AbXHIQGG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 12:06:06 -0400
In-Reply-To: <20070809142430.GA19817@shell.boston.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Historically this has been
> +accomplished by declaring the counter itself to be volatile, but the
> +ambiguity of the C standard on the semantics of volatile make this 
> practice
> +vulnerable to overly creative interpretation by compilers.

It's even worse when accessing through a volatile casted pointer;
see for example the recent(*) GCC bugs in that area.

(*) Well, not _all_ that recent.  No one should be using the 3.x
series anymore, right?

> Explicit
> +casting in atomic_read() ensures consistent behavior across 
> architectures
> +and compilers.

Even modulo compiler bugs, what makes you believe that?


Segher

