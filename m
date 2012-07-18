From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/15] ipv4: Cache input routes in fib_info nexthops.
Date: Wed, 18 Jul 2012 12:30:49 -0700 (PDT)
Message-ID: <20120718.123049.1074327576453628377.davem@davemloft.net>
References: <20120718.112413.1969496621247659288.davem@davemloft.net>
	<1342639675.2013.18.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37557 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755465Ab2GRTau (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 15:30:50 -0400
In-Reply-To: <1342639675.2013.18.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Wed, 18 Jul 2012 12:27:55 -0700

> Maybe a helper like:
> 
> 	if (some_do_cache_name(rth, res, itag, flags, &do_cache))
> 		goto foo;

Yep that would make a lot of sense.
