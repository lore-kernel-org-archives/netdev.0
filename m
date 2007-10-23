From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] flush_work_sync vs. flush_scheduled_work Re: [PATCH] PHYLIB: IRQ event workqueue handling fixes
Date: Tue, 23 Oct 2007 11:21:27 +0200
Message-ID: <20071023092127.GB1847@ff.dom.local>
References: <Pine.LNX.4.64N.0710151737250.16262@blysk.ds.pg.gda.pl> <20071016062108.GB1000@ff.dom.local> <Pine.LNX.4.64N.0710161759050.22596@blysk.ds.pg.gda.pl> <20071017085809.GA1658@ff.dom.local> <20071018063157.GA1694@ff.dom.local> <20071018070531.GA2065@ff.dom.local> <20071018154819.GA425@tv-sign.ru> <20071019075014.GA1765@ff.dom.local> <20071022061143.GA973@ff.dom.local> <20071022180259.GA967@tv-sign.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Maciej W\. Rozycki" <macro@linux-mips.org>,
	Andy Fleming <afleming@freescale.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Oleg Nesterov <oleg@tv-sign.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:47557 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751455AbXJWJSL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2007 05:18:11 -0400
Content-Disposition: inline
In-Reply-To: <20071022180259.GA967@tv-sign.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 22, 2007 at 10:02:59PM +0400, Oleg Nesterov wrote:
...
> If this work doesn't rearm itself - yes. (otherwise, the same ->func
> can run twice _at the same time_)
> 
> But again, in this case wait_on_work() after try_to_grab_pending() == 1
> doesn't block, so we can just do
> 
> 	if (cancel_work_sync(w))
> 		w->func();
> 

...but, if it were run just before work_clear_pending()?

Jarek P.
