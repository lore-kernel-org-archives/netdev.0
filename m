From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC] net: change bridge/macvlan hook to be be generic
Date: Mon, 10 May 2010 10:14:42 -0700
Message-ID: <4BE83F02.3010204@candelatech.com>
References: <C80610E0.2E2EC%scofeldm@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:51143 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755664Ab0EJROw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 13:14:52 -0400
In-Reply-To: <C80610E0.2E2EC%scofeldm@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/04/2010 05:58 PM, Scott Feldman wrote:
> On 5/4/10 3:37 PM, "Stephen Hemminger"<shemminger@vyatta.com>  wrote:
>
>> The existing macvlan and bridge have special hooks in the packet input
>> path. This patch changes it to a generic hook chain, like the packet type
>> processing. I have been wanting to look into flow based switching, etc...
>
> Can this be further simplified by saying that a netdev can only be hooked by
> one mux (macvlan, bridge, etc) at any given time, so there is never more
> than one element in the hook chain.  If so, then we just need a single hook,
> not a chain.
>
> It seems odd to me that a dev would have both macvlan_port != NULL and
> br_port != NULL.  Can dev be in a macvlan and a bridge at the same time?

If we did add the generic hook list, then we could support other hooks, like
a pktgen rx hook to gather latency, pkt-loss, and similar stats, for example.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
