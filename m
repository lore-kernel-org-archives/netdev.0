From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: Add support for SMSC/Microchip LAN9303 3-port switch
Date: Thu, 27 Feb 2014 14:21:49 -0800
Message-ID: <CAGVrzcZd7mO6t4eAsn6HVNWFZpPopkBk2trjgSh+3rcWQPHw7g@mail.gmail.com>
References: <1393492072-15364-1-git-send-email-sr@denx.de> <20140227.170240.1910151216729314077.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stefan Roese <sr@denx.de>, netdev <netdev@vger.kernel.org>,
	r.meier@siemens.com, lukas.stockmann@siemens.com
To: David Miller <davem@davemloft.net>, Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:64882 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752337AbaB0WWa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 17:22:30 -0500
Received: by mail-pa0-f45.google.com with SMTP id lf10so3090177pab.18
        for <netdev@vger.kernel.org>; Thu, 27 Feb 2014 14:22:30 -0800 (PST)
In-Reply-To: <20140227.170240.1910151216729314077.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-02-27 14:02 GMT-08:00 David Miller <davem@davemloft.net>:
> From: Stefan Roese <sr@denx.de>
> Date: Thu, 27 Feb 2014 10:07:52 +0100
>
>> This driver exposes a sysfs interface to access the LAN9303 registers to
>> userspace. These sysfs files can be used to configure the switch.
>>
>> Signed-off-by: Stefan Roese <sr@denx.de>
>
> We have an abstraction for programming switch devices called DSA.
>
> Even if DSA doesn't fullfill your needs, doing adjustments using sysfs
> files in userland is going to be the worst user experience possible.

If you remember the discussion that started around the 'swconfig'
patches, DSA is not suitable for all types of switches, especially not
those which have no proprietary tagging support (which are about 80%
of the switches used in embedded systems). That discussion has kind of
stalled now, so we should probably bring it back...

>
> Every driver will export different things to tweak, each device will
> have different semantics and limitations for these settings, etc.
>
> Better is to come up with a real, types, interface for programming
> such devices and providing an implementation of that.

These are definitively the goals of the 'swconfig' patches that were
posted a while ago, to provide an unified programming API.
-- 
Florian
