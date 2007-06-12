From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Tue, 12 Jun 2007 18:01:27 -0400
Message-ID: <466F17B7.2020600@garzik.org>
References: <466F0D78.7090404@candelatech.com>	<20070612.142658.45082832.davem@davemloft.net>	<466F142C.4040109@garzik.org> <20070612.145348.22503996.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, netdev@vger.kernel.org, kaber@trash.net,
	hadi@cyberus.ca, peter.p.waskiewicz.jr@intel.com,
	auke-jan.h.kok@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58764 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751713AbXFLWBb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2007 18:01:31 -0400
In-Reply-To: <20070612.145348.22503996.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Jeff Garzik <jeff@garzik.org>
> Date: Tue, 12 Jun 2007 17:46:20 -0400
> 
>> Not quite...  You'll have to deal with multiple Rx filters, not just the 
>> current one-filter-for-all model present in today's NICs.  Pools of 
>> queues will have separate configured characteristics.  The "steer" 
>> portion you mention is a bottleneck that wants to be eliminated.
> 
> It runs in hardware at wire speed, what's the issue? :-)

Configuration is the issue.

Where shall we put the configuration machinery, to support sub-queues?
Shall we duplicate the existing configuration code for sub-queues?
What will ifconfig/ip usage look like?
How will it differ from configuring full net_devices, if you are 
assigning the same types of parameters?  Why?

	Jeff


