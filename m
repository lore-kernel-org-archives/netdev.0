From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Wed, 21 Jan 2009 09:54:01 +0000
Message-ID: <20090121095401.GB5140@ff.dom.local>
References: <20090120102053.GA17004@ff.dom.local> <20090120103122.GC9167@ioremap.net> <20090120110144.GB17004@ff.dom.local> <20090120.091616.224452074.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: zbr@ioremap.net, herbert@gondor.apana.org.au, w@1wt.eu,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:41428 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754768AbZAUJyJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 04:54:09 -0500
Content-Disposition: inline
In-Reply-To: <20090120.091616.224452074.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 20, 2009 at 09:16:16AM -0800, David Miller wrote:
...
> Jarek, we already have a page and offset you can use.
> 
> It's called sk_sndmsg_page but that is just the (current) name.
> Nothing prevents you from reusing it for your purposes here.

I'm trying to get some know-how about this field.

Thanks,
Jarek P.
