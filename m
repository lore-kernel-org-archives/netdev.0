From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add regs attribute to phy device for user diagnose
Date: Mon, 16 Jan 2017 16:54:01 -0500 (EST)
Message-ID: <20170116.165401.1642553705400599921.davem@davemloft.net>
References: <20170115172150.GC5643@lunn.ch>
        <1484571579.3374.4.camel@163.com>
        <cf3e3125-582f-8b91-9c23-05dbdd2c6d24@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: cugyly@163.com, andrew@lunn.ch, netdev@vger.kernel.org,
        Linyu.Yuan@alcatel-sbell.com.cn
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49478 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750996AbdAPVyG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 16:54:06 -0500
In-Reply-To: <cf3e3125-582f-8b91-9c23-05dbdd2c6d24@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon, 16 Jan 2017 12:22:16 -0800

> On 01/16/2017 04:59 AM, yuan linyu wrote:
>> On 日, 2017-01-15 at 18:21 +0100, Andrew Lunn wrote:
>>> On Sun, Jan 15, 2017 at 09:51:03AM +0800, yuan linyu wrote:
>>>>  
>>>> I hope user/developer can read this attribute file "regs" to do
>>>> a full check of all registers value, and they can write any register
>>>> inside PHY through this file.
>>> Since this is intended for debug, it should not be sysfs, but debugfs.
>> agree,
>>> However, in general, Linux does not allow user space to peek and poke
>>> device registers. Can you point me at examples where i can do the same
>>> to my GPU? SATA controller? Ethernet controller, I2C temperature
>>> sensor? Any device?
>> we can read registers of ethernet controller(memory register accessed) through devmem or ethtool
> 
> So why not add support in ethtool for reading PHY registers if you need
> it? There are handful of PHY "things" in ethtool, such as reading
> counters, configuring downshift etc., adding support for dumping
> registers does not sound out of space.

Agreed.
