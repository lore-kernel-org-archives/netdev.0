From: "Denis V. Lunev" <den@sw.ru>
Subject: Re: [NET] IPv6 oops bisected
Date: Mon, 08 Oct 2007 11:00:31 +0400
Message-ID: <4709D58F.2030802@sw.ru>
References: <20071008061942.GA842@gondor.apana.org.au>	<20071007.232302.78733656.davem@davemloft.net>	<4709CF6F.60102@sw.ru> <20071007.234606.111182047.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jeff@garzik.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:55340 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751459AbXJHG65 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Oct 2007 02:58:57 -0400
In-Reply-To: <20071007.234606.111182047.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: "Denis V. Lunev" <den@sw.ru>
> Date: Mon, 08 Oct 2007 10:34:23 +0400
> 
>> OK. I am installing Fedora 7 right now...
> 
> You don't need to install Fedora, just read the code! :-)
> 
> The bug is obvious and it's been explained thoroughly in this
> thread.
> 
> When 'dev' is NULL in ip6_route_add() we need to figure out what
> namespace and/or loopback device you want to use.
> 
> There is no reason to do an entire dist install to work on fixing this
> bug, yikes!

I do understand the conditions when the bug happens. Its completely
clear :) Though I do not understand how to trigger it from command line
to test that the problem is resolved. Jeff was not kind enough to give
exact command line :(

The unfortunate thing with this place is that original Eric's code is
also broken here. I was too optimistic working on the original patchset.
In other way, but broken :(

So, I must stop and think...
