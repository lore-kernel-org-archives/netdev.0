From: Benny Amorsen <benny+usenet@amorsen.dk>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Wed, 04 Feb 2009 10:41:44 +0100
Message-ID: <m3skmubktj.fsf@ursa.amorsen.dk>
References: <20090203094108.GA4639@ff.dom.local>
	<20090203111012.GA16878@ioremap.net>
	<20090203112431.GA8746@gondor.apana.org.au>
	<20090203.164630.173080148.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, zbr@ioremap.net, jarkao2@gmail.com,
	w@1wt.eu, dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate1.ipvision.dk ([217.195.186.3]:58154 "EHLO
	gate1.ipvision.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751562AbZBDLOo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 06:14:44 -0500
In-Reply-To: <20090203.164630.173080148.davem@davemloft.net> (David Miller's message of "Tue\, 03 Feb 2009 16\:46\:30 -0800 \(PST\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Herbert Xu <herbert@gondor.apana.org.au>

>> Granted copying sucks, but this is really because the underlying
>> hardware is badly designed.  Also copying is way better than
>> not receiving at all due to memory fragmentation.
>
> This scheme sounds very reasonable.

Would it be possible to add a counter somewhere for this, or is that
too expensive?


/Benny

