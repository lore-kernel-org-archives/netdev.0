From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Sat, 10 Jan 2009 02:01:24 +0300
Message-ID: <20090109230124.GA11592@ioremap.net>
References: <4966F2F4.9080901@cosmosbay.com> <49677074.5090802@cosmosbay.com> <20090109185448.GA1999@1wt.eu> <4967B8C5.10803@cosmosbay.com> <20090109212400.GA3727@1wt.eu> <20090109220737.GA4111@1wt.eu> <4967CBB9.1060403@cosmosbay.com> <20090109221744.GA4819@1wt.eu> <20090109224258.GA10257@ioremap.net> <20090109225010.GB4819@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>, ben@zeus.com,
	jarkao2@gmail.com, mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cs-studio.ru ([195.178.208.66]:51549 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753414AbZAIXB0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 18:01:26 -0500
Content-Disposition: inline
In-Reply-To: <20090109225010.GB4819@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 09, 2009 at 11:50:10PM +0100, Willy Tarreau (w@1wt.eu) wrote:
> Well, I'm now trying to educate myself on the send part. It's still
> not very clear to me and I'd like to understand a little bit better
> why we have this corruption problem and why there is a difference
> between sending segments from memory and sending them from another
> socket where they were already waiting.

printks are the best choice, since you will get exactly what you are
looking for instead of deciphering what developer or code told you.

> I think I'll put printks everywhere and see what I can observe.
> Knowing about the GSO/SG workaround already helps me enable/disable
> the bug.

I wish I could also be capable to disable the bugs... :)

-- 
	Evgeniy Polyakov
