From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 3/4] net: avoid false perf interpretations in
 frag code
Date: Wed, 24 Apr 2013 19:54:58 -0400 (EDT)
Message-ID: <20130424.195458.116577525066604563.davem@davemloft.net>
References: <20130424154624.16883.40974.stgit@dragon>
	<20130424154836.16883.79599.stgit@dragon>
	<1366847307.8964.89.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, hannes@stressinduktion.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45125 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758268Ab3DXXzA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 19:55:00 -0400
In-Reply-To: <1366847307.8964.89.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 24 Apr 2013 16:48:27 -0700

> noinline can make sense when we want to avoid consuming too much stack
> space, and in this case we use the explicit noinline_for_stack.
> 
> Another case would be when we know a particular function is called on
> very rare occasions, and we want to avoid compiler being smart and
> inline the function in the caller.

Yet another case is where we must force the function in a special
section, f.e. __kprobes.
