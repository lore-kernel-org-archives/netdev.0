From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC] ipv6_fib limit spinlock hold times for
 /proc/net/ipv6_route
Date: Thu, 24 Apr 2014 07:30:32 -0700
Message-ID: <1398349832.29914.69.camel@edumazet-glaptop2.roam.corp.google.com>
References: <535918BC.5030708@fb.com>
	 <20140424142030.GD1960@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Chris Mason <clm@fb.com>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:58381 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756018AbaDXOad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 10:30:33 -0400
Received: by mail-pb0-f51.google.com with SMTP id uo5so2014609pbc.24
        for <netdev@vger.kernel.org>; Thu, 24 Apr 2014 07:30:33 -0700 (PDT)
In-Reply-To: <20140424142030.GD1960@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-04-24 at 16:20 +0200, Hannes Frederic Sowa wrote:

> I am planing to submit patches which reduce the caching of DST_HOST
> entries in the ipv6 fib next month which will result in a much smaller
> fib to walk by then.

Or, if caching is still needed, we might use a separate hash table for
this, as it is more scalable.
