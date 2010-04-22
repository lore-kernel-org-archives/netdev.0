From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] WAN: flush tx_queue in hdlc_ppp to prevent panic on
 rmmod hw_driver.
Date: Thu, 22 Apr 2010 14:43:39 -0700 (PDT)
Message-ID: <20100422.144339.128290761.davem@davemloft.net>
References: <m3mxx5mv8v.fsf@intrepid.localdomain>
	<4BD0A0B9.2070709@ruggedcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khc@pm.waw.pl, netdev@vger.kernel.org
To: michaelbarkowski@ruggedcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43206
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751611Ab0DVVnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 17:43:35 -0400
In-Reply-To: <4BD0A0B9.2070709@ruggedcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Barkowski <michaelbarkowski@ruggedcom.com>
Date: Thu, 22 Apr 2010 15:17:13 -0400

> Krzysztof Halasa wrote:
>> tx_queue is used as a temporary queue when not allowed to queue skb
>> directly to the hw device driver (which may sleep). Most paths flush
>> it before returning, but ppp_start() currently cannot. Make sure we
>> don't leave skbs pointing to a non-existent device.
>> 
>> Thanks to Michael Barkowski for reporting this problem.
> 
> Great - thanks.  Will this be going into -stable?

When I think it's cooked long enough in Linus's tree and
I submit it there.  That can take a few weeks.

