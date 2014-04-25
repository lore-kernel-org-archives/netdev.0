From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] ipv6_fib limit spinlock hold times for /proc/net/ipv6_route
Date: Fri, 25 Apr 2014 23:31:40 +0200
Message-ID: <20140425213140.GE7050@order.stressinduktion.org>
References: <535918BC.5030708@fb.com> <20140424142030.GD1960@order.stressinduktion.org> <53592287.2050902@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Chris Mason <clm@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:40551 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750835AbaDYVbl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2014 17:31:41 -0400
Content-Disposition: inline
In-Reply-To: <53592287.2050902@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 24, 2014 at 10:41:11AM -0400, Chris Mason wrote:
> I was going to discuss the cache exclusion on a separate thread, but the 
> short version is that I don't have any clue of how many people we'd 
> upset by unconditionally leaving out the cached entries.

In my opinion this would be ok.

We definitely must reduce number of entries in the fib and I don't think it is
wise to synthesize them thereafter, especially if we don't need to track state
at all, e.g. forwarding.
