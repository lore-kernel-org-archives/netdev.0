From: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Subject: Re: [PATCH] fib_rules: add .suppress operation
Date: Sun, 28 Jul 2013 12:36:34 +0200
Message-ID: <20130728103634.GI10216@zirkel.wertarbyte.de>
References: <20130725221116.GC10216@zirkel.wertarbyte.de>
 <20130726104657.GF10216@zirkel.wertarbyte.de>
 <20130727070758.GA23904@order.stressinduktion.org>
 <20130727102149.GH10216@zirkel.wertarbyte.de>
 <20130727151046.GB23904@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, Andrew Collins <bsderandrew@gmail.com>,
	stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zirkel.wertarbyte.de ([188.40.44.137]:60792 "EHLO
	zirkel.wertarbyte.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753345Ab3G1Kgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jul 2013 06:36:36 -0400
Content-Disposition: inline
In-Reply-To: <20130727151046.GB23904@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dies schrieb Hannes Frederic Sowa (hannes@stressinduktion.org):

> This should fix the compile error (was a c&p error from me in the previous
> mail).
> 
> -               if (!(fib_flags & FIB_LOOKUP_NOREF))
> +               if (!(arg->flags & FIB_LOOKUP_NOREF))
> 
> This should get a considerable amount of stress testing now. ;)

I amended that change and made a forced push, so now the branch should be up to
date and in working condition:
https://github.com/wertarbyte/linux/compare/fib_rule_suppress
