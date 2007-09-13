From: Kyle McMartin <kyle@mcmartin.ca>
Subject: Re: [CORRECTION][PATCH] Fix a potential NULL pointer dereference in uli526x_interrupt() in drivers/net/tulip/uli526x.c
Date: Thu, 13 Sep 2007 05:03:18 -0400
Message-ID: <20070913090318.GA6196@fattire.cabal.ca>
References: <46DD13CE.6010905@gmail.com> <20070913020346.979647c1.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Micah Gruber <micah.gruber@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com, Grant Grundler <grundler@parisc-linux.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stout.engsoc.carleton.ca ([134.117.69.22]:45593 "EHLO
	stout.engsoc.carleton.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756057AbXIMJSv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2007 05:18:51 -0400
Content-Disposition: inline
In-Reply-To: <20070913020346.979647c1.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 13, 2007 at 02:03:46AM -0700, Andrew Morton wrote:
> I suspect the fix we want is:
> 

ack. The trend seems to be to avoid this redundant check in the
interrupt handler.
