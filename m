From: akepner@sgi.com
Subject: Re: [PATCH] limit rt cache size
Date: Tue, 8 Aug 2006 17:06:31 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0608081659250.2452@localhost.localdomain>
References: <44D75EF8.1070901@sw.ru> <200608080711.06788.ak@suse.de>
 <Pine.LNX.4.61.0608081316330.2452@localhost.localdomain> <200608090123.01123.ak@suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	dev@sw.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from omx2-ext.sgi.com ([192.48.171.19]:57806 "EHLO omx2.sgi.com")
	by vger.kernel.org with ESMTP id S1030331AbWHIAQM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2006 20:16:12 -0400
To: Andi Kleen <ak@suse.de>
In-Reply-To: <200608090123.01123.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 9 Aug 2006, Andi Kleen wrote:

> ....
> I don't think it makes any sense to continue scaling at all after
> some point - you won't get better shorter hash chains anymore and the
> large hash tables actually cause problems: e.g. there are situations where we walk
> the complete tables and that takes longer and longer.
>

Logarithmic growth is _much_ slower than linear growth, so
scaling becomes quite restrained after the linear/logarithmic
boundary is exceeded.

> Also does a 1TB machine really need bigger hash tables than a 100GB one?
>

Maybe - depends on what the machine is used for, I suppose.

> The problem is to find out what a good boundary is.

True, and every choice involves some arbitrariness. But
the arbitariness in my example is at least well contained
(2 values). Anyway, I think there are good arguments for log
scaling these kinds of things after some point.

-- 
Arthur

