From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: + gen_estimator-fix-locking-and-timer-related-bugs.patch added to -mm tree
Date: Fri, 6 Jul 2007 08:26:29 +0200
Message-ID: <20070706062629.GC1846@ff.dom.local>
References: <200706271921.l5RJLgCC003910@imap1.linux-foundation.org> <1183642800.3789.11.camel@ranko-fc2.spidernet.net> <20070705142135.GG4759@ff.dom.local> <1183646029.4069.11.camel@ranko-fc2.spidernet.net> <1183651165.4069.26.camel@ranko-fc2.spidernet.net> <20070706061420.GA1846@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, kaber@trash.net, netdev@vger.kernel.org
To: Ranko Zivojnovic <ranko@spidernet.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:37764 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757490AbXGFGR7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2007 02:17:59 -0400
Content-Disposition: inline
In-Reply-To: <20070706061420.GA1846@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 06, 2007 at 08:14:20AM +0200, Jarek Poplawski wrote:
...
> This new lockup bug you have just found needs some time
> to figure out. BTW, I wonder if you had lockdep on
> (CONFIG_PROVE_LOCKING or CONFIG_LOCK_ALLOC)?

Should be:
(CONFIG_PROVE_LOCKING or CONFIG_DEBUG_LOCK_ALLOC)?

Jarek P.
