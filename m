From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Wed, 4 Feb 2009 11:08:51 +0300
Message-ID: <20090204080851.GA10445@ioremap.net>
References: <20090202.235017.253437221.davem@davemloft.net> <20090203094108.GA4639@ff.dom.local> <20090203111012.GA16878@ioremap.net> <20090203.164609.160183741.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, herbert@gondor.apana.org.au, w@1wt.eu,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kandzendo.ru ([195.178.208.66]:59125 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751423AbZBDIIy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Feb 2009 03:08:54 -0500
Content-Disposition: inline
In-Reply-To: <20090203.164609.160183741.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 03, 2009 at 04:46:09PM -0800, David Miller (davem@davemloft.net) wrote:
> > NTA tried to solve this by not allowing to free the data allocated on
> > the different CPU, contrary to what SLAB does. Modulo cache coherency
> > improvements,
> 
> This could kill performance on NUMA systems if we are not careful.
> 
> If we ever consider NTA seriously, these issues would need to
> be performance tested.

Quite contrary I think. Memory is allocated and freed on the same CPU,
which means on the same memory domain, closest to the CPU in question.

I did not test NUMA though, but NTA performance on the usual CPU (it is
2.5 years old already :) was noticebly good.

-- 
	Evgeniy Polyakov
