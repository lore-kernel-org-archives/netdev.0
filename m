From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Use routing mark from skb in multicast forwarding
 routing lookups
Date: Tue, 13 Oct 2009 03:33:45 -0700 (PDT)
Message-ID: <20091013.033345.216191487.davem@davemloft.net>
References: <200910071559.56526.atis@mikrotik.com>
	<20091007.135627.96995518.davem@davemloft.net>
	<200910081619.44880.atis@mikrotik.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, panther@balabit.hu, eric.dumazet@gmail.com,
	brian.haley@hp.com, zenczykowski@gmail.com
To: atis@mikrotik.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49746
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933858AbZJMKdt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 06:33:49 -0400
In-Reply-To: <200910081619.44880.atis@mikrotik.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Atis Elsts <atis@mikrotik.com>
Date: Thu, 8 Oct 2009 16:19:44 +0300

> On Wednesday 07 October 2009 23:56:27 David Miller wrote:
>> 
>> Ok submit just the else part and we'll have a look at it.
>> 
> Here is a try.
> 
> Use routing mark from skb in routing lookup in IPv4 and IPv6 multicast forwarding code.
> Signed-off-by: Atis Elsts <atis@mikrotik.com>

The more I think about the less this makes sense.

There is no way to setup these semantics of lower level
routes and satisfy every reasonable use case.

We'll need to provide another facility or suggest other
methods to control marking of encapsulated routes from
the socket level, sorry.
