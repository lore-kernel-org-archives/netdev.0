From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] fib_rules: add .suppress operation
Date: Sat, 27 Jul 2013 17:10:46 +0200
Message-ID: <20130727151046.GB23904@order.stressinduktion.org>
References: <20130725221116.GC10216@zirkel.wertarbyte.de> <20130726104657.GF10216@zirkel.wertarbyte.de> <20130727070758.GA23904@order.stressinduktion.org> <20130727102149.GH10216@zirkel.wertarbyte.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, Andrew Collins <bsderandrew@gmail.com>,
	stephen@networkplumber.org
To: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:43243 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752014Ab3G0PKt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Jul 2013 11:10:49 -0400
Content-Disposition: inline
In-Reply-To: <20130727102149.GH10216@zirkel.wertarbyte.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 27, 2013 at 12:21:49PM +0200, Stefan Tomanek wrote:
> Thanks for your input, I've put together all the proposed patches in my github
> branch:
> 
> https://github.com/wertarbyte/linux/compare/fib_rule_suppress
> 
> Any more ideas, before I squash it all together?

This should fix the compile error (was a c&p error from me in the previous
mail).

-               if (!(fib_flags & FIB_LOOKUP_NOREF))
+               if (!(arg->flags & FIB_LOOKUP_NOREF))

This should get a considerable amount of stress testing now. ;)

Greetings,

  Hannes
