From: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Subject: Re: [PATCH] fib_rules: add minimum prefix length
Date: Thu, 25 Jul 2013 18:29:32 +0200
Message-ID: <20130725162931.GX10216@zirkel.wertarbyte.de>
References: <20130723220221.GP10216@zirkel.wertarbyte.de>
 <20130724021420.GA10670@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zirkel.wertarbyte.de ([188.40.44.137]:34740 "EHLO
	zirkel.wertarbyte.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754591Ab3GYQ3d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 12:29:33 -0400
Received: from stefan by zirkel.wertarbyte.de with local (Exim 4.72)
	(envelope-from <stefan.tomanek@wertarbyte.de>)
	id 1V2OQ0-0000Vv-16
	for netdev@vger.kernel.org; Thu, 25 Jul 2013 18:29:32 +0200
Content-Disposition: inline
In-Reply-To: <20130724021420.GA10670@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dies schrieb Hannes Frederic Sowa (hannes@stressinduktion.org):

> I would try to factor the prefixlen_min check out into a
> e.g. fib4_rule_constrain function for which a new field in fib_rules_ops
> needs to be created as callback. Also it would be nice to have IPv6
> support, too. ;)

I was working on my patchset again and considered your suggestion; however I'm
not sure whether factoring out the constraints into a separate function is
actually that useful, since they are only called from one specific location for
each protocol; can you think of another useful application?

I however did like the idea of adding IPv6 support, so I did -
I'll post the new patch later on.

Thanks for your feedback.
