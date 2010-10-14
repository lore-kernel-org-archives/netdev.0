From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: [PATCH net-next] net:  allocate skbs on local node
Date: Thu, 14 Oct 2010 09:22:35 +0300
Message-ID: <4CB6A1AB.4030800@cs.helsinki.fi>
References: <1286838210.30423.128.camel@edumazet-laptop> <1286839363.30423.130.camel@edumazet-laptop> <1286859925.30423.184.camel@edumazet-laptop> <20101011230322.f0f6dd47.akpm@linux-foundation.org> <1286866699.30423.234.camel@edumazet-laptop> <20101012002435.f51f2c0e.akpm@linux-foundation.org> <1286869793.2732.24.camel@edumazet-laptop> <20101012005856.994bea6d.akpm@linux-foundation.org> <4CB441CB.2000708@cs.helsinki.fi> <alpine.DEB.2.00.1010120745360.31832@router.home> <alpine.DEB.2.00.1010121234380.10165@chino.kir.corp.google.com> <alpine.DEB.2.00.1010131056180.29099@router.home> <alpine.DEB.2.00.1010131342310.15185@chino.kir.corp.google.com> <alpine.DEB.2.00.1010131642220.8351@router.home> <alpine.DEB.2.00.1010131539440.27839@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <cl@linux.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Christoph Hellwig <hch@lst.de>,
	LKML <linux-kernel@vger.kernel.org>,
	Nick Piggin <npiggin@kernel.dk>
To: David Rientjes <rientjes@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:57315 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754702Ab0JNGWh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Oct 2010 02:22:37 -0400
In-Reply-To: <alpine.DEB.2.00.1010131539440.27839@chino.kir.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 Oct 2010, Christoph Lameter wrote:
>>> I was going to mention that as an idea, but I thought storing the metadata
>>> for certain debugging features might differ from the two allocators so
>>> substantially that it would be even more convoluted and difficult to
>>> maintain?
>>
>> We could have some callbacks to store allocator specific metadata?

On 10/14/10 1:41 AM, David Rientjes wrote:
> It depends on whether we could share the same base for both slab (unified
> allocator) and slub, which you snipped from your reply, that would make
> this cleaner.

Argh. Why would we want to introduce something that's effectively a new 
allocator based on SLUB? If there's something controversial in the 
current patch series, lets just keep it out of mainline. A "rewrite" is 
the reason we're in this mess so lets not repeat the same mistake again!

			Pekka
