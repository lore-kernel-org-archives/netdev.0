From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH net-next] net:  allocate skbs on local node
Date: Wed, 13 Oct 2010 15:41:23 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1010131539440.27839@chino.kir.corp.google.com>
References: <1286838210.30423.128.camel@edumazet-laptop> <1286839363.30423.130.camel@edumazet-laptop> <1286859925.30423.184.camel@edumazet-laptop> <20101011230322.f0f6dd47.akpm@linux-foundation.org> <1286866699.30423.234.camel@edumazet-laptop>
 <20101012002435.f51f2c0e.akpm@linux-foundation.org> <1286869793.2732.24.camel@edumazet-laptop> <20101012005856.994bea6d.akpm@linux-foundation.org> <4CB441CB.2000708@cs.helsinki.fi> <alpine.DEB.2.00.1010120745360.31832@router.home>
 <alpine.DEB.2.00.1010121234380.10165@chino.kir.corp.google.com> <alpine.DEB.2.00.1010131056180.29099@router.home> <alpine.DEB.2.00.1010131342310.15185@chino.kir.corp.google.com> <alpine.DEB.2.00.1010131642220.8351@router.home>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pekka Enberg <penberg@cs.helsinki.fi>,
	Andrew Morton <akpm@linux-foundation.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Christoph Hellwig <hch@lst.de>,
	LKML <linux-kernel@vger.kernel.org>,
	Nick Piggin <npiggin@kernel.dk>
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:34652 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753425Ab0JMWlc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 18:41:32 -0400
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id o9DMfUl9013354
	for <netdev@vger.kernel.org>; Wed, 13 Oct 2010 15:41:30 -0700
Received: from pzk3 (pzk3.prod.google.com [10.243.19.131])
	by wpaz24.hot.corp.google.com with ESMTP id o9DMfTAh002534
	for <netdev@vger.kernel.org>; Wed, 13 Oct 2010 15:41:29 -0700
Received: by pzk3 with SMTP id 3so423874pzk.39
        for <netdev@vger.kernel.org>; Wed, 13 Oct 2010 15:41:28 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1010131642220.8351@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 Oct 2010, Christoph Lameter wrote:

> > I was going to mention that as an idea, but I thought storing the metadata
> > for certain debugging features might differ from the two allocators so
> > substantially that it would be even more convoluted and difficult to
> > maintain?
> 
> We could have some callbacks to store allocator specific metadata?
> 

It depends on whether we could share the same base for both slab (unified 
allocator) and slub, which you snipped from your reply, that would make 
this cleaner.
