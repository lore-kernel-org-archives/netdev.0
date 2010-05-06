From: Ben Greear <greearb@candelatech.com>
Subject: Re: ixgbe and mac-vlans problem
Date: Thu, 06 May 2010 09:23:10 -0700
Message-ID: <4BE2ECEE.7070200@candelatech.com>
References: <4BDA07DB.8020206@candelatech.com> <201004302000.58763.arnd@arndb.de> <4BDB1CF3.8030906@candelatech.com> <EA929A9653AAE14F841771FB1DE5A1365FE55609F0@rrsmsx501.amr.corp.intel.com> <4BDB57A6.1090400@candelatech.com> <EA929A9653AAE14F841771FB1DE5A1365FE5560B00@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, NetDev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:39300 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932311Ab0EFQXU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 12:23:20 -0400
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365FE5560B00@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/30/2010 03:26 PM, Tantilov, Emil S wrote:
> Ben Greear wrote:
>> On 04/30/2010 02:13 PM, Tantilov, Emil S wrote:

>>> I ran a quick test in my setup with 82599 and was able to pass
>>> traffic on all 50 mac-vlans without issues. This is on net-next.
>>
>> For an 82599 system, I can get 127 mac-vlans working out of 500
>> created.
>>
>> That NIC also does not go PROMISC with lots (500) of mac-vlans.
>>
>> Once I put it in promisc mode manually, it works fine.
>>
>> So, I think whatever logic is supposed to put the NIC into promisc
>> mode when it overflows it's lookup tables isn't working for ixgbe
>> in 2.6.31.12.
>
> Yeah, you're right. I was able to repro it.
>
> We'll look into it.

I'd be happy to test out a patch if you have one available.

If you don't expect to have one soon, please let me know and
I'll add work-arounds to my code to throw ixgbe NICs into PROMISC
mode manually.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

