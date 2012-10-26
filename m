From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/9] net/macb: driver enhancement concerning GEM
 support, ring logic and cleanup
Date: Fri, 26 Oct 2012 14:59:38 -0400 (EDT)
Message-ID: <20121026.145938.2087989420370212890.davem@davemloft.net>
References: <cover.1348055112.git.nicolas.ferre@atmel.com>
	<508AAB54.9010506@atmel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manabian@gmail.com, netdev@vger.kernel.org, havard@skinnemoen.net,
	bhutchings@solarflare.com, linux-arm-kernel@lists.infradead.org,
	plagnioj@jcrosoft.com, patrice.vilchez@atmel.com,
	linux-kernel@vger.kernel.org
To: nicolas.ferre@atmel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <508AAB54.9010506@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicolas Ferre <nicolas.ferre@atmel.com>
Date: Fri, 26 Oct 2012 17:25:08 +0200

> David,
> 
> On 09/19/2012 01:55 PM, Nicolas Ferre :
>> This is an enhancement work that began several years ago. I try to catchup with
>> some performance improvement that has been implemented then by Havard.
>> The ring index logic and the TX error path modification are the biggest changes
>> but some cleanup/debugging have been added along the way.
>> The GEM revision will benefit from the Gigabit support.
>> 
>> The series has been tested on several Atmel AT91 SoC with the two MACB/GEM
>> flavors.
>> 
>> v2: - modify the tx error handling: now uses a workqueue
>>     - information provided by ethtool -i were not accurate: removed
> 
> I am about to re-send this patch series. Should I rebase it on top of
> Joachim's recent modifications? I mean, I plan to rebase them on top of
> net-next, is it the proper thing to do?

You should always base your patch on whatever tree you want your patches
applied to.

If you have a dependency on something not in that tree (for example, you
need something in the 'net' tree) you have to tell me.
