From: Ben Greear <greearb@candelatech.com>
Subject: Re: Missing device binding relating to tcp_v4_send_reset?
Date: Tue, 10 Aug 2010 07:22:41 -0700
Message-ID: <4C6160B1.3040501@candelatech.com>
References: <4C603EF2.9010902@candelatech.com> <20100810.014846.258126767.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:46660 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932102Ab0HJOWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 10:22:47 -0400
In-Reply-To: <20100810.014846.258126767.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/10/2010 01:48 AM, David Miller wrote:
> From: Ben Greear<greearb@candelatech.com>
> Date: Mon, 09 Aug 2010 10:46:26 -0700
>
>> This snippet is from some patches Patrick did for me some time
>> back.  I think the rest of his work has been merged upstream, but
>> this patch was not.  I'm honestly not sure if it's needed or not,
>> but we've been running with it for at least a year or so and it's
>> been working fine for us.
>
> There is no reason at all to force a reply to a packet to
> go out of the same interface as the packet which triggered
> that reply arrived upon.

Ok, in my case I *did* want this behaviour..it makes send-to-self,
BIND_TO_DEVICE and virtual routers and such work properly if I
recall correctly.

Would you consider a sysctl to enable this feature, with it disabled
by default?  Please note there are similar sysctls for ICMP already...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
