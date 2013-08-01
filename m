From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] fib_rules: add .suppress operation
Date: Wed, 31 Jul 2013 17:26:43 -0700 (PDT)
Message-ID: <20130731.172643.1587377835518449424.davem@davemloft.net>
References: <20130730074636.GC10550@zirkel.wertarbyte.de>
	<20130731.151354.1698882304457097890.davem@davemloft.net>
	<20130801002407.GL10550@zirkel.wertarbyte.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	bsderandrew@gmail.com
To: stefan.tomanek@wertarbyte.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36398 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750856Ab3HAA0o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 20:26:44 -0400
In-Reply-To: <20130801002407.GL10550@zirkel.wertarbyte.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Date: Thu, 1 Aug 2013 02:24:07 +0200

> Dies schrieb David Miller (davem@davemloft.net):
> 
>> I just want to mention that the more quirky crap we put into the FIB
>> rules layer, the harder it will every be to make a scalable data
>> structure for FIB rule handling.
>> 
>> Right now it's basically a linear walk of rules, with processing at
>> each level.
> 
> And it still is: but instead of just having pre-conditions whether to
> consult a table, the patch introduces post-conditions that can reject
> a routing decision retrieved from it.

This doesn't change my argument at all.  The fact remains that the
more complex conditions we add to the fib rule lookup, the harder it
will be to optimize fib rule lookups into an O(1) or O(log n)
operation.
