From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Races in net_rx_action vs netpoll?
Date: Mon, 16 Jul 2007 10:06:50 +0200
Message-ID: <20070716080650.GA2297@ff.dom.local>
References: <20070712125949.GC1708@ff.dom.local> <200707121554.33915.okir@lst.de> <20070713085508.GC2009@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Olaf Kirch <okir@lst.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:34585 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753729AbXGPH55 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2007 03:57:57 -0400
Content-Disposition: inline
In-Reply-To: <20070713085508.GC2009@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 13, 2007 at 10:55:08AM +0200, Jarek Poplawski wrote:
> On Thu, Jul 12, 2007 at 03:54:32PM +0200, Olaf Kirch wrote:
...
> > One thing I was a little worried about was whether dev->npinfo can
> > go away all of a sudden. It's really just protected by an rcu_readlock...
...
> BTW, I don't think there could be any problem with rcu (if it's
> all about calling dev->poll from poll_napi) because then poll_napi
> should have the same problem.

To do it justice: I've missed your point, but of course you are
right the validity of dev->npinfo should be analyzed with such
a solution too.

Regards,
Jarek P.
