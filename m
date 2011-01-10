From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [PATCH] Cleanup include/net/tcp.h include-files and
 coding-style
Date: Mon, 10 Jan 2011 07:50:32 -0800
Message-ID: <20110110075032.e38955ef.rdunlap@xenotime.net>
References: <1294606534-28522-1-git-send-email-christoph.paasch@uclouvain.be>
	<1294614389.2823.35.camel@localhost>
	<AANLkTik7mug7j=VLz80DX_hJokeO3=ie+KRcMViSL4kB@mail.gmail.com>
	<201101101244.24932.christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([72.52.115.56]:39929 "HELO xenotime.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752246Ab1AJPue (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jan 2011 10:50:34 -0500
Received: from chimera.site ([173.50.240.230]) by xenotime.net for <netdev@vger.kernel.org>; Mon, 10 Jan 2011 07:50:33 -0800
In-Reply-To: <201101101244.24932.christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 10 Jan 2011 12:44:24 +0100 Christoph Paasch wrote:

> 
> On Monday, January 10, 2011 wrote Alexey Dobriyan:
> > >> linux/percpu_counter.h (needed for percpu_counter_sum_positive)
> > > 
> > > Yes.
> > 
> > Currently code compiles fine, so necessary headers are in place,
> > so simply adding new headers doesn't help anything.
> 
> I totally agree with you.
> However we need a consistent coding style.
> 
> Or we just include the minimum necessary headers (as originally proposed by 
> me).
> Or we include every header whose structs/functions are referenced.
> 
> In my opinion the current "mixed" state is not ok, because some includes are 
> there because there *are* references (even if these includes could be omitted, 
> e.g., linux/list.h).
> Other includes (like linux/percpu_counter.h) are not there, because they are 
> indirectly included by another header and thus the code compiles. Even if 
> there are references.
> And there are no rules/guidelines to identify the headers that should be 
> included and those that should not.

Documentation/SubmitChecklist, #1:

1: If you use a facility then #include the file that defines/declares
   that facility.  Don't depend on other header files pulling in ones
   that you use.


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
