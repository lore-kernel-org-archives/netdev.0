From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] Introduce and use printk pointer extension %pV
Date: Fri, 02 Jul 2010 22:32:44 -0700 (PDT)
Message-ID: <20100702.223244.193707555.davem@davemloft.net>
References: <cover.1277636090.git.joe@perches.com>
	<20100630.130709.93452021.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, greg@kroah.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40949
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751707Ab0GCFcb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Jul 2010 01:32:31 -0400
In-Reply-To: <20100630.130709.93452021.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 30 Jun 2010 13:07:09 -0700 (PDT)

> From: Joe Perches <joe@perches.com>
> Date: Sun, 27 Jun 2010 04:02:32 -0700
> 
>> Recursive printk can reduce the total image size of an x86 defconfig about 1% 
>> by reducing duplicated KERN_<level> strings and centralizing the functions
>> used by macros in new separate functions.
>> 
>> Joe Perches (4):
>>   vsprintf: Recursive vsnprintf: Add "%pV", struct va_format
>>   device.h drivers/base/core.c Convert dev_<level> logging macros to functions
>>   netdevice.h net/core/dev.c: Convert netdev_<level> logging macros to functions
>>   netdevice.h: Change netif_<level> macros to call netdev_<level> functions
> 
> I'm fine with this, thanks Joe.
> 
> Greg, could you ACK this and let me know if it's OK if it swings
> through my net-next-2.6 tree?

Greg, ping?
