From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn: remove spellcaster driver
Date: Tue, 01 Dec 2015 16:07:09 -0500 (EST)
Message-ID: <20151201.160709.566323664243976564.davem@davemloft.net>
References: <2948626.r4RdgunA3R@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2948626.r4RdgunA3R@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 30 Nov 2015 11:34:09 +0100

> The 'sc' ISDN driver relies on using readl() to access ISA I/O memory.
> This has been deprecated and produced warnings since linux-2.3.23,
> disabled by default since 2.4.10 and finally removed in 2.6.5.
> 
> I found this because the compiling the driver for ARM produces
> a warning:
> 
> In file included from ../drivers/isdn/sc/includes.h:8:0,
>                  from ../drivers/isdn/sc/init.c:13:
> ../arch/arm/include/asm/io.h:115:21: note: expected 'const volatile void *' but argument is of type 'long unsigned int'
> 
> It is pretty clear that this driver has not been used for a long time
> and there is no point fixing it now, so let's remove it.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
> There has been some discussion about removing all the ISA based ISDN
> drivers in the past. I'm not trying to restart that discussion at the
> moment, and I did not find the same bug in the other drivers, so
> let's just remove this one for now.

Applied to net-next, we can resurrect+fix this driver if someone actually
uses it.

Thanks Arnd.
