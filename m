From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH net-next] net:  allocate skbs on local node
Date: Tue, 12 Oct 2010 23:31:07 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1010122330090.13748@chino.kir.corp.google.com>
References: <1286838210.30423.128.camel@edumazet-laptop> <1286839363.30423.130.camel@edumazet-laptop> <1286859925.30423.184.camel@edumazet-laptop> <20101011230322.f0f6dd47.akpm@linux-foundation.org> <1286866699.30423.234.camel@edumazet-laptop>
 <20101012002435.f51f2c0e.akpm@linux-foundation.org> <1286869793.2732.24.camel@edumazet-laptop> <20101012005856.994bea6d.akpm@linux-foundation.org> <4CB441CB.2000708@cs.helsinki.fi> <alpine.DEB.2.00.1010120745360.31832@router.home>
 <alpine.DEB.2.00.1010121234380.10165@chino.kir.corp.google.com> <4CB54EE8.4020707@kernel.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
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
To: Pekka Enberg <penberg@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:39499 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751175Ab0JMGbN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 02:31:13 -0400
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id o9D6VCeX015930
	for <netdev@vger.kernel.org>; Tue, 12 Oct 2010 23:31:12 -0700
Received: from pvc22 (pvc22.prod.google.com [10.241.209.150])
	by wpaz9.hot.corp.google.com with ESMTP id o9D6VAq3030735
	for <netdev@vger.kernel.org>; Tue, 12 Oct 2010 23:31:10 -0700
Received: by pvc22 with SMTP id 22so748322pvc.30
        for <netdev@vger.kernel.org>; Tue, 12 Oct 2010 23:31:10 -0700 (PDT)
In-Reply-To: <4CB54EE8.4020707@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 Oct 2010, Pekka Enberg wrote:

> I think Christoph is saying that we'd remove SLAB and make the unified
> allocator the new SLAB while keeping SLUB in place.

Right, so his unification patches would be against slab instead of slub 
which is a pretty major change from the current state of the patchset, 
although it might actually be smaller?
