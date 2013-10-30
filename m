From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: introduce new IP_MTU_DISCOVER mode
 IP_PMTUDISC_INTERFACE
Date: Wed, 30 Oct 2013 17:36:08 -0400 (EDT)
Message-ID: <20131030.173608.2156276556221568210.davem@davemloft.net>
References: <20131029.000844.1092862708536984032.davem@davemloft.net>
	<20131029120424.GD26185@order.stressinduktion.org>
	<20131030200725.GB9093@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fweimer@redhat.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34690 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797Ab3J3Vg3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 17:36:29 -0400
In-Reply-To: <20131030200725.GB9093@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 30 Oct 2013 21:07:25 +0100

> On Tue, Oct 29, 2013 at 01:04:25PM +0100, Hannes Frederic Sowa wrote:
>> I really tried hard to find alternatives or even a way to enable
>> the protection automatically given that at least unbound does apply
>> IP_PMTUDISC_DONT to its sockets already. These are the reasons why I
>> came up with the new IP_PMTUDISC_INTERFACE value:
> 
> Sorry to bother you but I would really love to hear your feedback on my
> reasoning so I can try to come up with a solution you would be happy with.

All I've read is that administrators cannot be relied upon to
configure their systems properly for the requirements they have.

And that is a non-argument for adding this new socket option as far as
I'm concerned.

"I strongly do not trust path MTU information" has a scope as small as
a route or an interface, it doesn't go down to the socket or
application level at all.

Please stop pretending that it does.
