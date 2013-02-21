From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] ipv6: use a stronger hash for tcp
Date: Thu, 21 Feb 2013 15:49:16 -0800
Message-ID: <m2fw0pxm6b.fsf@firstfloor.org>
References: <1361485132.17413.19.camel@edumazet-glaptop>
	<20130221.181822.1234155083700257175.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	ncardwell@google.com, ycheng@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:51256 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754322Ab3BUXtS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Feb 2013 18:49:18 -0500
In-Reply-To: <20130221.181822.1234155083700257175.davem@davemloft.net> (David
	Miller's message of "Thu, 21 Feb 2013 18:18:22 -0500 (EST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:
>
> I bet we can consolidate this slightly, to make it less
> expensive yet not give up much in terms of protection.  Two
> jhash3word()'s is quite a lot.

jhash is not really the state of the art for general hashing anymore,
murmur3 or cityhash are generally considered faster/possibly better.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only
