From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH]: Preliminary release of Sun Neptune driver
Date: Wed, 19 Sep 2007 18:40:05 -0400
Message-ID: <46F1A545.7010700@garzik.org>
References: <20070918.151528.84360712.davem@davemloft.net>	<20070919145900.759ef19e@freepuppy.rosehill.hemminger.net> <20070919.150755.38714639.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	Ariel.Hendel@sun.com, greg.onufer@sun.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36929 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753440AbXISWkJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2007 18:40:09 -0400
In-Reply-To: <20070919.150755.38714639.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
>> Macro's that make assumptions about context (ie variable name np)
>> are evil and bad style.
> 
> Too bad, it saves developers who write 20,000 line drivers from carpel
> tunnel symdrome.
> 
> It's so repetitive to state things over and over again, and this macro
> scheme is 1) established widely (tg3 amonst many other drivers do it)
> and 2) forces the driver to use a consistent naming convention for
> primary driver private struct variables.

It also makes review easier -- IMO an important factor.

Which is more clear at a glance:

	status = tr32(MAC_STAT_1);

or

	status = foo_mac_read32(priv, MAC_STAT_1);

?

tg3 and other net drivers show that this technique improves code 
readability.

	Jeff


