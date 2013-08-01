From: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Subject: Re: [PATCH v3] fib_rules: add .suppress operation
Date: Thu, 1 Aug 2013 02:24:07 +0200
Message-ID: <20130801002407.GL10550@zirkel.wertarbyte.de>
References: <20130727070758.GA23904@order.stressinduktion.org>
 <20130730074636.GC10550@zirkel.wertarbyte.de>
 <20130731.151354.1698882304457097890.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	bsderandrew@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zirkel.wertarbyte.de ([188.40.44.137]:58184 "EHLO
	zirkel.wertarbyte.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750857Ab3HAAYI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 20:24:08 -0400
Content-Disposition: inline
In-Reply-To: <20130731.151354.1698882304457097890.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dies schrieb David Miller (davem@davemloft.net):

> I just want to mention that the more quirky crap we put into the FIB
> rules layer, the harder it will every be to make a scalable data
> structure for FIB rule handling.
> 
> Right now it's basically a linear walk of rules, with processing at
> each level.

And it still is: but instead of just having pre-conditions whether to
consult a table, the patch introduces post-conditions that can reject
a routing decision retrieved from it.

> Anyways, there are coding style problems in your change which you'll
> need to address:

Fixed in latest patch, thanks for the hints.
