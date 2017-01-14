From: David VomLehn <vomlehn@texas.net>
Subject: Re: [PATCH v5 00/13] net: ethernet: aquantia: Add AQtion 2.5/5 GB NIC
 driver
Date: Fri, 13 Jan 2017 19:41:22 -0800
Message-ID: <1473b399-9f4e-0046-c176-e4d43533b09c@texas.net>
References: <cover.1484283610.git.vomlehn@texas.net>
 <9a4e95cc-9daa-f883-46c0-f477e28b9f0f@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda2.aus1.datafoundry.com ([209.99.124.133]:50752 "EHLO
        milter.aus.datafoundry.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750808AbdAND6o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 22:58:44 -0500
In-Reply-To: <9a4e95cc-9daa-f883-46c0-f477e28b9f0f@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/13/2017 05:38 PM, Florian Fainelli wrote:
> On 01/12/2017 09:02 PM, Alexander Loktionov wrote:
>> From: David VomLehn <vomlehn@texas.net>
>>
>> v1: Initial version
>> v2: o Make necessary drivers/net/ethernet changes to integrate software
>>      o Drop intermediate atlantic directory
>>      o Remove Makefile things only appropriate to out of tree module
>>        building
>> v3: o Move changes to drivers/net/ethernet/{Kconfig,Makefile} to the last
>>        patch to ensure clean bisection.
>>      o Removed inline attribute aq_hw_write_req() as it was defined in
>>        only one .c file.
>>      o #included pci.h in aq_common.h to get struct pci definition.
>>      o Modified code to unlock based execution flow rather than using a
>>        flag.
>>      o Made a number of functions that were only used in a single file
>>        static.
>>      o Cleaned up error and return code handling in various places.
>>      o Remove AQ_CFG_IP_ALIGN definition.
>>      o Other minor code clean up.
>> v4: o Using do_div for 64 bit division.
>>      o Modified NIC statistics code.
>>      o Using build_skb instead netdev_alloc_skb for single fragment
>>        packets.
>>      o Removed extra aq_nic.o from Makefile
>> v5: o Removed extra newline at the end of the files.
>>      o Wrapped cover letter lines.
> Have not looked at the driver yet, but the threading of your emails is
> weird, each patch is in reply to the previous one. It would be more
> natural to have all numbered patches be in reply to the cover letter,
> which according to the version of git you seem to have used (2.7.4)
> should already be the default. In graphical terms what we see right now is:
>
> [PATCH 00/13]
> 	[PATCH 01/13]
> 		[PATCH 02/13]
> 			....
>
> While we should see:
>
>
> [PATCH 00/13]
> 	[PATCH 01/13]
> 	[PATCH 02/13]
> 	....
>
> Can you fix that for future submissions, this may sound like a cosmetic
> thing, but it really helps with threading/reading etc.
>
> Thanks!
This looks like it is a consequence of setting the git configuration 
item format.thread to deep. I've switched it to shallow, which should 
give the threading you suggest.

-- 
David VL
