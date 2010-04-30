From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: ixgbe and mac-vlans problem
Date: Fri, 30 Apr 2010 15:13:47 -0600
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365FE55609F0@rrsmsx501.amr.corp.intel.com>
References: <4BDA07DB.8020206@candelatech.com>
 <201004302000.58763.arnd@arndb.de> <4BDB1CF3.8030906@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: NetDev <netdev@vger.kernel.org>, Patrick McHardy <kaber@trash.net>
To: Ben Greear <greearb@candelatech.com>, Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:36393 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757441Ab0D3VNs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 17:13:48 -0400
In-Reply-To: <4BDB1CF3.8030906@candelatech.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear wrote:
> On 04/30/2010 11:00 AM, Arnd Bergmann wrote:
>> On Friday 30 April 2010 00:27:39 Ben Greear wrote:
>>> Basically, we create 50 mac-vlans, with sequential MAC addresses
>>> and sequential IP addresses, and set up ip rules properly.
>>> 
>>> The issue is that only 10 or so of the mac-vlans receive other than
>>> broadcast packets.  The ixgbe NIC doesn't show PROMISC mode.
>> 
>> I just took a brief look at the driver and noticed that 82599 should
>> be able to handle 128 entries before going into promisc mode, while
>> 82598 (the same driver) does 16.
>> 
>> Maybe the logic for>16 entries is wrong, so you could try forcing
>> hw->mac.num_rar_entries to 16 for 82599 as well.
> 
> I think I was actually on an 825998 system when I saw it yesterday,
> but I have seen similar issues on 82599, though I didn't take time
> to debug it fully, so it could have been something else.
> 
> I will double-check the NIC chipset on the system that showed the
> problem yesterday.

I ran a quick test in my setup with 82599 and was able to pass traffic 
on all 50 mac-vlans without issues. This is on net-next.

Thanks,
Emil

