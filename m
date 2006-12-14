From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH 12/14] Spidernet Avoid possible RX chain corruption
Date: Thu, 14 Dec 2006 11:15:11 -0600
Message-ID: <20061214171511.GT4329@austin.ibm.com>
References: <20061213210010.GR4329@austin.ibm.com> <20061213212301.GL1915@austin.ibm.com> <1166055763.6838.5.camel@concordia.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
	linuxppc-dev@ozlabs.org, Jens Osterkamp <Jens.Osterkamp@gmx.de>,
	jgarzik@pobox.com, James K Lewis <jim@jklewis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:42425 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932864AbWLNRPO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Dec 2006 12:15:14 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id kBEHFDI8004026
	for <netdev@vger.kernel.org>; Thu, 14 Dec 2006 12:15:13 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kBEHFDiJ296344
	for <netdev@vger.kernel.org>; Thu, 14 Dec 2006 12:15:13 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kBEHFCwj013732
	for <netdev@vger.kernel.org>; Thu, 14 Dec 2006 12:15:13 -0500
To: Michael Ellerman <michael@ellerman.id.au>
Content-Disposition: inline
In-Reply-To: <1166055763.6838.5.camel@concordia.ozlabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 14, 2006 at 11:22:43AM +1100, Michael Ellerman wrote:
> >  	spider_net_refill_rx_chain(card);
> > -	spider_net_enable_rxchtails(card);
> >  	spider_net_enable_rxdmac(card);
> >  	return 0;
> 
> Didn't you just add that line?

Dagnabbit. The earlier pach was moving around existing code.
Or, more precisely, trying to maintain the general function
of the old code even while moving things around.

Later on, when I started looking at what the danged function 
actually did, and the context it was in, I realized that it 
was a bad idea to call the thing.  So then I removed it. :-/

How should I handle this proceedurally? Resend the patch sequence? 
Let it slide?

--linas

