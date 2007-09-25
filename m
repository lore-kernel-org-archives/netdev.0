From: Urs Thuermann <urs@isnogud.escape.de>
Subject: Re: [PATCH 4/7] CAN: Add broadcast manager (bcm) protocol
Date: 25 Sep 2007 15:26:03 +0200
Message-ID: <ygfmyvaev10.fsf@janus.isnogud.escape.de>
References: <20070925122029.15989.0@janus.isnogud.escape.de>
	<20070925122243.15989.4@janus.isnogud.escape.de>
	<20070925125122.GD18348@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Joe Perches <joe@perches.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:56909 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751956AbXIYNbO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Sep 2007 09:31:14 -0400
In-Reply-To: <20070925125122.GD18348@ghostprotocols.net>; from Arnaldo Carvalho de Melo on Tue, 25 Sep 2007 09:51:22 -0300
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnaldo Carvalho de Melo <acme@ghostprotocols.net> writes:

> > +	skb = alloc_skb(CFSIZ,
> > +			in_interrupt() ? GFP_ATOMIC : GFP_KERNEL);
> 
> We have gfp_any() for this:

Ah, ok.  That looks better.  Applied.

urs
