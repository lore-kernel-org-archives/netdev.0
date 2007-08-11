From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH 1/24] make atomic_read() behave consistently on alpha
Date: Sat, 11 Aug 2007 02:50:25 +0200
Message-ID: <12943ce306ab975fd589bbf5e8b14167@kernel.crashing.org>
References: <E1IJPkg-0000x0-00@gondolin.me.apana.org.au> <442f95ba19f8622ce04cf0334f34be11@kernel.crashing.org> <20070811000029.GA12779@gondor.apana.org.au> <ef7e94b08a6515d33039d187e04db5db@kernel.crashing.org> <20070811004322.GA13178@gondor.apana.org.au>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, heiko.carstens@de.ibm.com,
	horms@verge.net.au, linux-kernel@vger.kernel.org,
	csnook@redhat.com, rpjday@mindspring.com, netdev@vger.kernel.org,
	ak@suse.de, cfriesen@nortel.com, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, jesper.juhl@gmail.com,
	linux-arch@vger.kernel.org, zlynx@acm.org, schwidefsky@de.ibm.com,
	davem@davemloft.net, wensong@linux-vs.org, wjiang@resilience.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:60345 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756584AbXHKAv3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2007 20:51:29 -0400
In-Reply-To: <20070811004322.GA13178@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>> That means GCC cannot compile Linux; it already optimises
>>>> some accesses to scalars to smaller accesses when it knows
>>>> it is allowed to.  Not often though, since it hardly ever
>>>> helps in the cost model it employs.
>>>
>>> Please give an example code snippet + gcc version + arch
>>> to back this up.
>>
>> 	unsigned char f(unsigned long *p)
>> 	{
>> 	        return *p & 1;
>> 	}
>
> This doesn't really matter since we only care about the LSB.

It is exactly what I claimed, and what you asked proof of.

> Do you have an example where gcc reads it non-atmoically and
> we care about all parts?

Like I explained in the original mail; no, I suspect such
a testcase will be really hard to construct, esp. as a small
testcase.  I have no reason to believe it is impossible to
do so though -- maybe someone else can write trickier code
than I can, in which case, please do so.


Segher

