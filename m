From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] PHYLIB: IRQ event workqueue handling fixes
Date: Wed, 17 Oct 2007 11:09:46 +0200
Message-ID: <20071017090946.GB1658@ff.dom.local>
References: <20071015125301.GC3015@ff.dom.local> <Pine.LNX.4.64N.0710151737250.16262@blysk.ds.pg.gda.pl> <20071016062108.GB1000@ff.dom.local> <Pine.LNX.4.64N.0710161759050.22596@blysk.ds.pg.gda.pl> <20071017085809.GA1658@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Fleming <afleming@freescale.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Maciej W\. Rozycki" <macro@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:56672 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753074AbXJQJGn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 05:06:43 -0400
Content-Disposition: inline
In-Reply-To: <20071017085809.GA1658@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 17, 2007 at 10:58:09AM +0200, Jarek Poplawski wrote:
...
> 5) phy_stop_interrupts(): maybe I miss something, but it seems
> phy_stop() is required before this, so maybe there should be a
> comment on this?
> 
> 6) phy_stop_interrupts(): if I'm not wrong with #3 calling

Should be:
  6) phy_stop_interrupts(): if I'm not wrong with #5 calling

Jarek P.
