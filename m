From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Sat, 18 Aug 2007 01:55:55 +0200
Message-ID: <899db25b292a84560e5cc955ebe4c9e1@kernel.crashing.org>
References: <E1ILCgh-00052A-00@gondolin.me.apana.org.au> <46C32618.2080108@redhat.com> <20070815234021.GA28775@gondor.apana.org.au> <3694fb2e4ed1e4d9bf873c0d050c911e@kernel.crashing.org> <46C3B50E.7010702@yahoo.com.au> <194369f4c96ea0e24decf8f9197d5bad@kernel.crashing.org> <46C505B2.6030704@yahoo.com.au> <18117.4848.695269.72976@cargo.ozlabs.ibm.com> <alpine.LFD.0.999.0708162033400.30176@woody.linux-foundation.org> <alpine.LFD.0.999.0708171016160.3666@enigma.security.iitk.ac.in> <f5796b5aa38ae6305c65ffa0340ba295@kernel.crashing.org> <alpine.LFD.0.999.0708180512300.3666@enigma.security.iitk.ac.in>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Paul Mackerras <paulus@samba.org>, heiko.carstens@de.ibm.com,
	horms@verge.net.au,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	rpjday@mindspring.com, ak@suse.de, netdev@vger.kernel.org,
	cfriesen@nortel.com, Nick Piggin <nickpiggin@yahoo.com.au>,
	linux-arch@vger.kernel.org, jesper.juhl@gmail.com,
	Andrew Morton <akpm@linux-foundation.org>, zlynx@acm.org,
	clameter@sgi.com, schwidefsky@de.ibm.com,
	Chris Snook <csnook@redhat.com>,
	Herbert Xu <herbert.xu@redhat.com>, davem@davemloft.net,
	Linus Torvalds <torvalds@linux-foundation.org>,
	wensong@linux-vs.org, wjiang@resilience.com
To: Satyam Sharma <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:56184 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752190AbXHQX5u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Aug 2007 19:57:50 -0400
In-Reply-To: <alpine.LFD.0.999.0708180512300.3666@enigma.security.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>> #define forget(a)	__asm__ __volatile__ ("" :"=m" (a) :"m" (a))
>>>
>>> [ This is exactly equivalent to using "+m" in the constraints, as 
>>> recently
>>>   explained on a GCC list somewhere, in response to the patch in my 
>>> bitops
>>>   series a few weeks back where I thought "+m" was bogus. ]
>>
>> [It wasn't explained on a GCC list in response to your patch, as
>> far as I can see -- if I missed it, please point me to an archived
>> version of it].
>
> http://gcc.gnu.org/ml/gcc-patches/2007-07/msg01758.html

Ah yes, that old thread, thank you.

> That's when _I_ came to know how GCC interprets "+m", but probably
> this has been explained on those lists multiple times. Who cares,
> anyway?

I just couldn't find the thread you meant, I thought I missed
have it, that's all :-)


Segher

