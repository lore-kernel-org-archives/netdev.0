From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] Introduce and use printk pointer extension %pV
Date: Wed, 30 Jun 2010 13:07:09 -0700 (PDT)
Message-ID: <20100630.130709.93452021.davem@davemloft.net>
References: <cover.1277636090.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, greg@kroah.com
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1277636090.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Sun, 27 Jun 2010 04:02:32 -0700

> Recursive printk can reduce the total image size of an x86 defconfig about 1% 
> by reducing duplicated KERN_<level> strings and centralizing the functions
> used by macros in new separate functions.
> 
> Joe Perches (4):
>   vsprintf: Recursive vsnprintf: Add "%pV", struct va_format
>   device.h drivers/base/core.c Convert dev_<level> logging macros to functions
>   netdevice.h net/core/dev.c: Convert netdev_<level> logging macros to functions
>   netdevice.h: Change netif_<level> macros to call netdev_<level> functions

I'm fine with this, thanks Joe.

Greg, could you ACK this and let me know if it's OK if it swings
through my net-next-2.6 tree?

Thanks.
