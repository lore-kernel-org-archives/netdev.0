From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Thu, 16 Aug 2007 21:33:40 +0200
Message-ID: <d4c6e3846c4171eb1e74d0874d7c3b60@kernel.crashing.org>
References: <E1ILCgh-00052A-00@gondolin.me.apana.org.au> <46C32618.2080108@redhat.com> <20070815234021.GA28775@gondor.apana.org.au> <20070815235125.GT9645@linux.vnet.ibm.com> <0de0c3d833b6f543bd75f74bb17a124b@kernel.crashing.org> <20070816023050.GC14613@linux.vnet.ibm.com>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: heiko.carstens@de.ibm.com, horms@verge.net.au,
	linux-kernel@vger.kernel.org, rpjday@mindspring.com, ak@suse.de,
	netdev@vger.kernel.org, cfriesen@nortel.com,
	akpm@linux-foundation.org, torvalds@linux-foundation.org,
	jesper.juhl@gmail.com, linux-arch@vger.kernel.org, zlynx@acm.org,
	satyam@infradead.org, clameter@sgi.com, schwidefsky@de.ibm.com,
	Chris Snook <csnook@redhat.com>,
	Herbert Xu <herbert.xu@redhat.com>, davem@davemloft.net,
	wensong@linux-vs.org, wjiang@resilience.com
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:54742 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759235AbXHPTjq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Aug 2007 15:39:46 -0400
In-Reply-To: <20070816023050.GC14613@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> The only thing volatile on an asm does is create a side effect
>> on the asm statement; in effect, it tells the compiler "do not
>> remove this asm even if you don't need any of its outputs".
>>
>> It's not disabling optimisation likely to result in bugs,
>> heisen- or otherwise; _not_ putting the volatile on an asm
>> that needs it simply _is_ a bug :-)
>
> Yep.  And the reason it is a bug is that it fails to disable
> the relevant compiler optimizations.  So I suspect that we might
> actually be saying the same thing here.

We're not saying the same thing, but we do agree :-)


Segher

