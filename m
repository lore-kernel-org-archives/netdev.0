From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH net-next] net:  allocate skbs on local node
Date: Wed, 13 Oct 2010 09:36:46 +0300
Message-ID: <4CB5537E.30906@kernel.org>
References: <1286838210.30423.128.camel@edumazet-laptop> <1286839363.30423.130.camel@edumazet-laptop> <1286859925.30423.184.camel@edumazet-laptop> <20101011230322.f0f6dd47.akpm@linux-foundation.org> <1286866699.30423.234.camel@edumazet-laptop> <20101012002435.f51f2c0e.akpm@linux-foundation.org> <1286869793.2732.24.camel@edumazet-laptop> <20101012005856.994bea6d.akpm@linux-foundation.org> <4CB441CB.2000708@cs.helsinki.fi> <alpine.DEB.2.00.1010120745360.31832@router.home> <alpine.DEB.2.00.1010121234380.10165@chino.kir.corp.google.com> <4CB54EE8.4020707@kernel.org> <alpine.DEB.2.00.1010122330090.13748@chino.kir.corp.google.com>
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
Received: from freeflow.nu ([178.79.134.28]:40528 "EHLO freeflow.nu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751916Ab0JMGgt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Oct 2010 02:36:49 -0400
In-Reply-To: <alpine.DEB.2.00.1010122330090.13748@chino.kir.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  On Wed, 13 Oct 2010, Pekka Enberg wrote:
>> I think Christoph is saying that we'd remove SLAB and make the unified
>> allocator the new SLAB while keeping SLUB in place.

On 10/13/10 9:31 AM, David Rientjes wrote:
>> Right, so his unification patches would be against slab instead of slub
>> which is a pretty major change from the current state of the patchset,
>> although it might actually be smaller?

No, the way I understood it was:

   rm mm/slab.c
   cp mm/slub.c mm/slab.c
<apply patches on top of slab.c>

             Pekka
