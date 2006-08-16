From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH 1/1] network memory allocator.
Date: Wed, 16 Aug 2006 09:38:59 +0400
Message-ID: <20060816053859.GC22921@2ka.mipt.ru>
References: <20060814110359.GA27704@2ka.mipt.ru> <1155558313.5696.167.camel@twins> <20060814123530.GA5019@2ka.mipt.ru> <1155639302.5696.210.camel@twins> <20060815112617.GB21736@2ka.mipt.ru> <1155643405.5696.236.camel@twins> <20060815123438.GA29896@2ka.mipt.ru> <1155649768.5696.262.camel@twins> <20060815141501.GA10998@2ka.mipt.ru> <20060815225237.03df7874.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: a.p.zijlstra@chello.nl, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:2448 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1750751AbWHPFjZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 01:39:25 -0400
To: Bill Fink <billfink@mindspring.com>
Content-Disposition: inline
In-Reply-To: <20060815225237.03df7874.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 15, 2006 at 10:52:37PM -0400, Bill Fink (billfink@mindspring.com) wrote:
> > Let's main system works only with TCP for simplicity.
> > Let's maximum allowed memory is limited by 1mb (it is 768k on machine
> > with 1gb of ram).
> 
> The maximum amount of memory available for TCP on a system with 1 GB
> of memory is 768 MB (not 768 KB).

It does not matter, let's it be 100mb or any other number, since
allocation is separated and does not depend on main system one.
Network allocator can steal pages from main one, but it does not suffer
from SLAB OOM.

Btw, I have a system with 1gb of ram and 1.5gb of low-mem tcp limit and
3gb of high-mem tcp memory limit calculated automatically.

-- 
	Evgeniy Polyakov
