From: David Miller <davem@davemloft.net>
Subject: Re: Custom hardware Qdisc...
Date: Fri, 11 Dec 2009 17:05:56 -0800 (PST)
Message-ID: <20091211.170556.67925441.davem@davemloft.net>
References: <4B228EC0.80105@caviumnetworks.com>
	<20091211.144021.192655356.davem@davemloft.net>
	<4B22EACA.2060407@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ddaney@caviumnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34102
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1763008AbZLLBFv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2009 20:05:51 -0500
In-Reply-To: <4B22EACA.2060407@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Daney <ddaney@caviumnetworks.com>
Date: Fri, 11 Dec 2009 16:58:50 -0800

> David Miller wrote:
>> From: David Daney <ddaney@caviumnetworks.com>
>> Date: Fri, 11 Dec 2009 10:26:08 -0800
>> 
>>> Our hardware (Octeon SOC) has fairly flexible packet output queuing
>>> that can be done completely in hardware.
>> You haven't described sufficiently what your hardware is
>> capable of.
>> 
> 
> Up to 16 output queues per port. With (almost) any combination of
> absolute and weighted priorities between the various queues.

It sounds like these queues could be configured to have equal
priorities and thus be used as purely a TX multiqueue scheme
for better scalability.

I suspect that doing that alone will fix the qdisc cache line bouncing
you mention.
