From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: [PATCH net-next v8 0/4] net: Add Keystone NetCP ethernet driver
 support
Date: Wed, 28 Jan 2015 11:49:44 -0500
Message-ID: <54C91328.6030208@ti.com>
References: <1421367007-19744-1-git-send-email-m-karicheri2@ti.com> <20150119.151106.822126941934010309.davem@davemloft.net> <54BE7A00.2020205@ti.com> <25883654.BLFxICW9P0@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <devicetree@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <25883654.BLFxICW9P0@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/27/2015 05:28 PM, Arnd Bergmann wrote:
> On Tuesday 20 January 2015 10:53:36 Murali Karicheri wrote:
>> On 01/19/2015 03:11 PM, David Miller wrote:
>>> From: Murali Karicheri<m-karicheri2@ti.com>
>>> Date: Thu, 15 Jan 2015 19:10:03 -0500
>>>
>>>> The Network Coprocessor (NetCP) is a hardware accelerator that processes
>>>> Ethernet packets. NetCP has a gigabit Ethernet (GbE) subsystem with a ethernet
>>>> switch sub-module to send and receive packets. NetCP also includes a packet
>>>> accelerator (PA) module to perform packet classification operations such as
>>>> header matching, and packet modification operations such as checksum
>>>> generation. NetCP can also optionally include a Security Accelerator(SA)
>>>> capable of performing IPSec operations on ingress/egress packets.
>>>>
>>>> Keystone SoC's also have a 10 Gigabit Ethernet Subsystem (XGbE) which
>>>> includes a 3-port Ethernet switch sub-module capable of 10Gb/s and
>>>> 1Gb/s rates per Ethernet port.
>>>>
>>>> Both GBE and XGBE network processors supported using common driver. It
>>>> is also designed to handle future variants of NetCP.
>>>
>>> Series applied to net-next, thanks.
>> David,
>>
>> Thanks a lot for applying this series. This helps us move forward to
>> work on the next set of patches.
>
> Hi Murali,
>
> Building an ARM 'allmodconfig' kernel now runs into two separate problems
> from your driver:
>
> - you have two module_init() instances in one module, which conflict.
>
> - you have two files that are linked into more than one module, so building
>    both TI_CPSW and TI_KEYSTONE_NETCP in the same kernel fails.
>
> The answer to both of these is probably to have separate loadable modules,
> but you might be able to come up with a different solution.
Arnd,

Thanks for letting us know. We will look into this.

How do I reproduce this? Is there a defconfig used for allmodconfig? I 
am unable to find one. Any details to reproduce this will be useful.

Thanks.

Murali
>
> 	Arnd


-- 
Murali Karicheri
Linux Kernel, Texas Instruments
