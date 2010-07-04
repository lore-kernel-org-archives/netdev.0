From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] Introduce and use printk pointer extension %pV
Date: Sun, 04 Jul 2010 10:40:52 -0700 (PDT)
Message-ID: <20100704.104052.112588682.davem@davemloft.net>
References: <20100630.130709.93452021.davem@davemloft.net>
	<20100702.223244.193707555.davem@davemloft.net>
	<20100703160857.GA29043@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: greg@kroah.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54237
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757844Ab0GDRkj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jul 2010 13:40:39 -0400
In-Reply-To: <20100703160857.GA29043@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg KH <greg@kroah.com>
Date: Sat, 3 Jul 2010 09:08:57 -0700

> On Fri, Jul 02, 2010 at 10:32:44PM -0700, David Miller wrote:
>> From: David Miller <davem@davemloft.net>
>> Date: Wed, 30 Jun 2010 13:07:09 -0700 (PDT)
>> 
>> > From: Joe Perches <joe@perches.com>
>> > Date: Sun, 27 Jun 2010 04:02:32 -0700
>> > 
>> >> Recursive printk can reduce the total image size of an x86 defconfig about 1% 
>> >> by reducing duplicated KERN_<level> strings and centralizing the functions
>> >> used by macros in new separate functions.
>> >> 
>> >> Joe Perches (4):
>> >>   vsprintf: Recursive vsnprintf: Add "%pV", struct va_format
>> >>   device.h drivers/base/core.c Convert dev_<level> logging macros to functions
>> >>   netdevice.h net/core/dev.c: Convert netdev_<level> logging macros to functions
>> >>   netdevice.h: Change netif_<level> macros to call netdev_<level> functions
>> > 
>> > I'm fine with this, thanks Joe.
>> > 
>> > Greg, could you ACK this and let me know if it's OK if it swings
>> > through my net-next-2.6 tree?
>> 
>> Greg, ping?
> 
> Sorry about the delay.
> 
> Yes, that's fine to take it through your tree, thanks for doing that:
> 	Acked-by: Greg Kroah-Hartman <gregkh@suse.de>

Thanks!  I've added this set to my tree.
