From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [RFC] restore netdev_priv optimization (planb)
Date: Fri, 17 Aug 2007 18:21:25 -0700
Message-ID: <46C64995.4030401@intel.com>
References: <20070817161928.6b6302fd@freepuppy.rosehill.hemminger.net>
	<20070817.165625.23014105.davem@davemloft.net>
	<20070817174909.5e890ad6@freepuppy.rosehill.hemminger.net>
 <20070817.180006.98552435.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms042pub.verizon.net ([206.46.252.42]:59381 "EHLO
	vms042pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750994AbXHRBVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 21:21:39 -0400
Received: from ahkok-mobl.jf.intel.com ([71.182.85.189])
 by vms042.mailsrvcs.net
 (Sun Java System Messaging Server 6.2-6.01 (built Apr  3 2006))
 with ESMTPA id <0JMY003WA3RQAE72@vms042.mailsrvcs.net> for
 netdev@vger.kernel.org; Fri, 17 Aug 2007 20:21:26 -0500 (CDT)
In-reply-to: <20070817.180006.98552435.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Fri, 17 Aug 2007 17:49:09 -0700
> 
>> Fix optimization of netdev_priv() lost by the addition of multiqueue.
>>
>> Only configurations that define MULITQUEUE need the extra overhead in
>> netdevice structure and the loss of the netdev_priv optimization.
>>
>> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> Every distribution vendor is going to turn MULTIQUEUE on.  Therefore
> %99 of Linux users will not see any gain from your patch.
> 
> You're walking around in a dark room and hitting walls every
> few seconds.  Take a moment and think about how to really deal
> with this generically for a second before churning out another
> patch.
> 
> For example, how about making the multiqueue limit fixed, say at 64
> queues, and declare the egress_queues as an array of 64 entries.  Then
> you can get constant pointer formation for both the netdev priv and
> the queues.

this sounds highly optimistic ("64 queues is enough for everyone"?) and probably 
will be quickly outdated by both hardware and demand...

Auke




