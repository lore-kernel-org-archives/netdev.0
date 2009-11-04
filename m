From: Naohiro Ooiwa <nooiwa@miraclelinux.com>
Subject: Re: [PATCH] e1000: the power down when running ifdown command
Date: Wed, 04 Nov 2009 19:27:11 +0900
Message-ID: <4AF156FF.5060000@miraclelinux.com>
References: <4AEC05E8.40600@miraclelinux.com>	 <9929d2390911021626j4a2e4a96neaba49ffd8775dc9@mail.gmail.com>	 <4AF00097.4040708@miraclelinux.com> <9929d2390911031337p6115fef0wc1b94e5141ead341@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com, peter.p.waskiewicz.jr@intel.com,
	john.ronciak@intel.com, davem@davemloft.net,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, svaidy@linux.vnet.ibm.com,
	e1000-devel@lists.sourceforge.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw.miraclelinux.com ([122.216.84.157]:9453 "EHLO
	mailgw.miraclelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752065AbZKDK1H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 05:27:07 -0500
In-Reply-To: <9929d2390911031337p6115fef0wc1b94e5141ead341@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote:
> 2009/11/3 Naohiro Ooiwa <nooiwa@miraclelinux.com>:
>> Jeff Kirsher wrote:
>>> 2009/10/31 Naohiro Ooiwa <nooiwa@miraclelinux.com>:
>>>
>>> I have added this patch to my tree for testing.  This patch requires a
>>> fair amount of regression testing, so once its passed testing I will
>>> push the patch to David/netdev.
>> I appreciate the marge your tree.
>> If there is anything I can do, please let me know.
>>
>> And I know this patch is good for e100 driver too.
>> I would really like to create patch for it.
>> How do you think about e100 driver.
>>
>>
>> Thanks,
>> Naohiro Ooiwa
>>
> 
> Patches are always welcome (referring to a e100 patch).

I am happy that you should say that.
I will try to create a patch for e100, e1000e, igb and ixgbe.
Before that, I should fix the following problems.


> As far as the e1000 patch goes, it has a number of issues which were
> found in testing.  Here are just a few problems we saw:
> 1. ethtool -t - crashes the system
> 2. ethtool eth0 - always shows link/speed as 1000/Full even when there
> is no cable
> 3. ethtool -s eth0 autoneg on/off - system hang. Sometimes a copper
> interface will show up as fiber after this.
> 4. ethtool -d/-S/-g etc - will corrupt the stats of the interface
> while doing ifup/down

Thank you for your tests.
Oh, My patch is full of problem.
The rest is my work.

I will resend the patch after test of all ethtool's options.
At that time, I will tell you contents of my tests.

And I sad WOL works on my patch in previous mail.
But WOL doesn't work. Sorry, I wasn't myself.
I will fix it too.

> 
> So it appears that more needs to be done to the driver to get this to
> work as expected.
> 
> NAK
> 







