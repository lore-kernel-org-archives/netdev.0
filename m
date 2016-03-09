From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] net: ipv4 -- Introduce ifa limit per net
Date: Wed, 09 Mar 2016 15:27:30 -0500 (EST)
Message-ID: <20160309.152730.691838022304871697.davem@davemloft.net>
References: <20160309170921.GL2207@uranus.lan>
	<20160309.122400.951958972682394628.davem@davemloft.net>
	<20160309175307.GM2207@uranus.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, solar@openwall.com, vvs@virtuozzo.com,
	avagin@virtuozzo.com, xemul@virtuozzo.com, vdavydov@virtuozzo.com,
	khorenko@virtuozzo.com
To: gorcunov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33506 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753847AbcCIU1d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 15:27:33 -0500
In-Reply-To: <20160309175307.GM2207@uranus.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cyrill Gorcunov <gorcunov@gmail.com>
Date: Wed, 9 Mar 2016 20:53:07 +0300

> On Wed, Mar 09, 2016 at 12:24:00PM -0500, David Miller wrote:
> ...
>> We asked you for numbers without a lot of features enabled, it'll
>> help us diagnose which subsystem still causes a lot of overhead
>> much more clearly.
>> 
>> So please do so.
> 
> Sure. Gimme some time and I'll back with numbers.
> 
>> Although it's already pretty clear that netfilter conntrack
>> cleanup is insanely expensive.
> 
> Yes. I can drop it off for a while and run tests without it,
> then turn it back and try again. Would you like to see such
> numbers?

That would be very helpful, yes.
