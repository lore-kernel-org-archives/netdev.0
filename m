From: Ben Greear <greearb@candelatech.com>
Subject: Re: ixgbe and mac-vlans problem
Date: Fri, 30 Apr 2010 11:09:55 -0700
Message-ID: <4BDB1CF3.8030906@candelatech.com>
References: <4BDA07DB.8020206@candelatech.com> <201004302000.58763.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>, Patrick McHardy <kaber@trash.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:57286 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758922Ab0D3SKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 14:10:04 -0400
In-Reply-To: <201004302000.58763.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/30/2010 11:00 AM, Arnd Bergmann wrote:
> On Friday 30 April 2010 00:27:39 Ben Greear wrote:
>> Basically, we create 50 mac-vlans, with sequential MAC addresses and sequential
>> IP addresses, and set up ip rules properly.
>>
>> The issue is that only 10 or so of the mac-vlans receive other than
>> broadcast packets.  The ixgbe NIC doesn't show PROMISC mode.
>
> I just took a brief look at the driver and noticed that 82599 should
> be able to handle 128 entries before going into promisc mode, while
> 82598 (the same driver) does 16.
>
> Maybe the logic for>16 entries is wrong, so you could try forcing
> hw->mac.num_rar_entries to 16 for 82599 as well.

I think I was actually on an 825998 system when I saw it yesterday,
but I have seen similar issues on 82599, though I didn't take time
to debug it fully, so it could have been something else.

I will double-check the NIC chipset on the system that showed the
problem yesterday.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

