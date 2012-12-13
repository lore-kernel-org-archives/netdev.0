From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv6: Change skb->data before using icmpv6_notify()
 to propagate redirect
Date: Thu, 13 Dec 2012 14:50:28 -0500 (EST)
Message-ID: <20121213.145028.509906659453424680.davem@davemloft.net>
References: <50C9BA41.1010507@gmail.com>
	<20121213.125911.566802923957164958.davem@davemloft.net>
	<1355427432.13796.43.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: djduanjiong@gmail.com, steffen.klassert@secunet.com,
	netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40636 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754791Ab2LMTuc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2012 14:50:32 -0500
In-Reply-To: <1355427432.13796.43.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Thu, 13 Dec 2012 11:37:12 -0800

> On Thu, 2012-12-13 at 12:59 -0500, David Miller wrote:
>> > +     hdr = (u8 *)ndopts.nd_opts_rh;
>> 
>> (u8 *)[SPACE]ndopts...
> 
> Really?
> 
> checkpatch bleats a --strict message:
> 
> CHECK: No space is necessary after a cast
> #5: FILE: t.c:5:
> +
> +	bar = *(int *) foo;

Ho hum, I'm actually ambivalent about this so...
