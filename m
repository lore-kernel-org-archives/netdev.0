From: Patrick McHardy <kaber@trash.net>
Subject: Re: Routing tables associated with VLANs dissappear when parent ethX
 down/up
Date: Wed, 21 Nov 2007 21:25:34 +0100
Message-ID: <4744943E.2010000@trash.net>
References: <474387E4.7020802@candelatech.com>	<47448C4F.3060107@candelatech.com> <20071121120027.54c277ea@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	NetDev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41339 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750866AbXKUUZo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 15:25:44 -0500
In-Reply-To: <20071121120027.54c277ea@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Wed, 21 Nov 2007 11:51:43 -0800
> Ben Greear <greearb@candelatech.com> wrote:
>
>   
>> For consideration, this patch seems to work for me.  I'm not sure
>> why we ever listed to these events.  I've only tested on a NIC that
>> doesn't support hw-accel at the moment..will test with e1000 later.
>>
>> Thanks,
>> Ben
>>
>>     
>
> But then if you are doing bonding or bridging of vlan's 
> and you bring down the root network device, the upper layer is not
> notified (for failover).
>   

operstate should be enough for this I guess. Ben, what does iproute show
for the vlan device when the lower device is down?

