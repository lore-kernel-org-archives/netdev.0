From: Ben Greear <greearb@candelatech.com>
Subject: Re: [net-next 2/2] macvlan:  Enable qdisc backoff logic.
Date: Wed, 25 Aug 2010 12:27:43 -0700
Message-ID: <4C756EAF.9090704@candelatech.com>
References: <1282762851-3612-1-git-send-email-greearb@candelatech.com> <1282762851-3612-2-git-send-email-greearb@candelatech.com> <201008252124.09917.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:44598 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752474Ab0HYT1s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 15:27:48 -0400
In-Reply-To: <201008252124.09917.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/25/2010 12:24 PM, Arnd Bergmann wrote:
> On Wednesday 25 August 2010 21:00:51 Ben Greear wrote:
>> This allows macvlans to apply backpressure to calling code
>> in the transmit path when the underlying qdisc cannot accept
>> additional packets.
>>
>> Signed-off-by: Ben Greear<greearb@candelatech.com>
>
> Ah, very nice! I was wondering how to do this.
>
> I suppose we need to do something in macvtap to handle this as
> well, right? A guest trying to send a frame through qemu
> or vhost net into macvtap needs to be prevented from sending
> more when we get into this path. Right now, we just ignore
> the return value of macvlan_start_xmit.

I have a similar, though slightly more complex, patch for 802.1q
vlans, but I haven't looked at macvtap at all.

If these two patches are accepted, I'll post the .1q patch as well.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

