From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Fri, 06 Feb 2009 01:49:31 -0800 (PST)
Message-ID: <20090206.014931.135139791.davem@davemloft.net>
References: <20090206091034.GA4879@ff.dom.local>
	<20090206.011722.41272682.davem@davemloft.net>
	<20090206094253.GB4879@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, zbr@ioremap.net, w@1wt.eu,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: jarkao2@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757452AbZBFJtq@vger.kernel.org>
In-Reply-To: <20090206094253.GB4879@ff.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Fri, 6 Feb 2009 09:42:53 +0000

> I hope you're right, but on the other hand, people don't use slob by
> default.

The use is different, so it's a bad comparison, really.

SLAB has to satisfy all kinds of object lifetimes, all kinds
of sizes and use cases, and perform generally well in all
situations with zero knowledge about usage patterns.

Networking is strictly the opposite of that set of requirements.  We
know all of these parameters (or their ranges) and can on top of that
control them if necessary.
