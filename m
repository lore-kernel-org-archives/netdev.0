From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] make atomic_t volatile on all architectures
Date: Sun, 12 Aug 2007 10:59:08 -0700 (PDT)
Message-ID: <alpine.LFD.0.999.0708121057500.30176@woody.linux-foundation.org>
References: <20070808230733.GA17270@shell.boston.redhat.com>
 <alpine.LFD.0.999.0708082116060.25146@woody.linux-foundation.org>
 <46BAC2BE.1090106@redhat.com> <46BB508B.7050601@redhat.com>
 <alpine.LFD.0.999.0708091055080.25146@woody.linux-foundation.org>
 <1186683646.9669.20.camel@localhost> <a599bc5062d557db46496f0d7c7886b0@kernel.crashing.org>
 <alpine.LFD.0.999.0708112305170.30176@woody.linux-foundation.org>
 <cbbe196cd30095e13e96762a6ddfd9a0@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: wjiang@resilience.com, wensong@linux-vs.org,
	heiko.carstens@de.ibm.com, linux-kernel@vger.kernel.org,
	ak@suse.de, cfriesen@nortel.com, netdev@vger.kernel.org,
	horms@verge.net.au, akpm@linux-foundation.org,
	schwidefsky@de.ibm.com, Chuck Ebbert <cebbert@redhat.com>,
	davem@davemloft.net, zlynx@acm.org, Chris Snook <csnook@redhat.com>
To: Segher Boessenkool <segher@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:55876 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751781AbXHLSAG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Aug 2007 14:00:06 -0400
In-Reply-To: <cbbe196cd30095e13e96762a6ddfd9a0@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Sun, 12 Aug 2007, Segher Boessenkool wrote:
> 
> It works _most of the time_.

It used to have problems. Gcc has had problems in various areas.

>			  Ask Martin.  Oh you don't even have to,
> he told you two mails ago.  My last mail simply pointed out that this
> isn't a GCC bug, but merely documented behaviour.

It was *not* documented behaviour, and there were gcc people who actively 
*encouraged* use of "+m", and actually fixed gcc.

The documentation is buggy.

Live with it.

			Linus
