From: Ben Greear <greearb@candelatech.com>
Subject: Re: Why is LRO off by default on ixgbe?
Date: Wed, 23 Sep 2009 09:57:51 -0700
Message-ID: <4ABA538F.7020507@candelatech.com>
References: <4ABA4D07.50107@candelatech.com> <20090923095356.7f9aef37@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:35954 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751057AbZIWQ5r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2009 12:57:47 -0400
In-Reply-To: <20090923095356.7f9aef37@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/23/2009 09:53 AM, Stephen Hemminger wrote:
> On Wed, 23 Sep 2009 09:29:59 -0700
> Ben Greear<greearb@candelatech.com>  wrote:
>
>> I just noticed that enabling LRO on ixgbe lets me reach about 9Gbps receive on two
>> NICs concurrently in an NFS test, where I was only getting about 6Gbps w/out it (1500 MTU).
>>
>> Why is LRO disabled by default?
>>
>> Thanks,
>> Ben
>
> LRO is turned off if bridging or routing because of End to End requirements.

That makes sense.

If I know that all interfaces in question can handle TSO and LRO,
I could manually enable LRO w/out risk, right?

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

