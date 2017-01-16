From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: add regs attribute to phy device for user diagnose
Date: Mon, 16 Jan 2017 12:22:16 -0800
Message-ID: <cf3e3125-582f-8b91-9c23-05dbdd2c6d24@gmail.com>
References: <1484361992-30591-1-git-send-email-cugyly@163.com>
 <20170114162453.GB1072@lunn.ch>
 <da255b0c-dba6-ef35-d436-3110d8492f95@gmail.com>
 <1484445063.4555.8.camel@163.com> <20170115172150.GC5643@lunn.ch>
 <1484571579.3374.4.camel@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: cugyly@163.com, Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34851 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750803AbdAPUWU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 15:22:20 -0500
Received: by mail-pf0-f193.google.com with SMTP id f144so14662309pfa.2
        for <netdev@vger.kernel.org>; Mon, 16 Jan 2017 12:22:19 -0800 (PST)
In-Reply-To: <1484571579.3374.4.camel@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/16/2017 04:59 AM, yuan linyu wrote:
> On 日, 2017-01-15 at 18:21 +0100, Andrew Lunn wrote:
>> On Sun, Jan 15, 2017 at 09:51:03AM +0800, yuan linyu wrote:
>>>  
>>> I hope user/developer can read this attribute file "regs" to do
>>> a full check of all registers value, and they can write any register
>>> inside PHY through this file.
>> Since this is intended for debug, it should not be sysfs, but debugfs.
> agree,
>> However, in general, Linux does not allow user space to peek and poke
>> device registers. Can you point me at examples where i can do the same
>> to my GPU? SATA controller? Ethernet controller, I2C temperature
>> sensor? Any device?
> we can read registers of ethernet controller(memory register accessed) through devmem or ethtool

So why not add support in ethtool for reading PHY registers if you need
it? There are handful of PHY "things" in ethtool, such as reading
counters, configuring downshift etc., adding support for dumping
registers does not sound out of space.
-- 
Florian
