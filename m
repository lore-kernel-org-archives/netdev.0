From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [NET]: gen_estimator: fix locking and timer related bugs [Re: [Bugme-new] [Bug 8668] New: HTB Deadlock]
Date: Fri, 29 Jun 2007 09:56:32 +0200
Message-ID: <20070629075632.GB1908@ff.dom.local>
References: <46824D88.1090300@trash.net> <20070627121013.GB3762@ff.dom.local> <468279FC.3070502@trash.net> <46827DB1.3060509@trash.net> <46828179.5030404@trash.net> <20070628091339.GC1618@ff.dom.local> <4683A848.5040907@trash.net> <20070628130335.GA3284@ff.dom.local> <4683AFD7.8080605@trash.net> <20070629070241.GA1908@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, ranko@spidernet.net
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:44130 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755919AbXF2HsR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2007 03:48:17 -0400
Content-Disposition: inline
In-Reply-To: <20070629070241.GA1908@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 29, 2007 at 09:02:41AM +0200, Jarek Poplawski wrote:
...
> same *bstats & *rate_est more than once (or max twice if we let
> to add, change & remove them independently).

...but this doesn't look sensible at all!

So, maybe, if we would need something counted with two intervals...
But, nobody seems to use such possibility, anyway.

Jarek P.
