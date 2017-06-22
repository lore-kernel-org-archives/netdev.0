From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: smsc: fix buffer overflow in memcpy
Date: Thu, 22 Jun 2017 11:12:59 -0400 (EDT)
Message-ID: <20170622.111259.2189237581775204039.davem@davemloft.net>
References: <20170620204059.790066-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, timur@codeaurora.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170620204059.790066-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 20 Jun 2017 22:40:46 +0200

> The memcpy annotation triggers for a fixed-length buffer copy:
> 
> In file included from /git/arm-soc/arch/arm64/include/asm/processor.h:30:0,
>                  from /git/arm-soc/arch/arm64/include/asm/spinlock.h:21,
>                  from /git/arm-soc/include/linux/spinlock.h:87,
>                  from /git/arm-soc/include/linux/seqlock.h:35,
>                  from /git/arm-soc/include/linux/time.h:5,
>                  from /git/arm-soc/include/linux/stat.h:21,
>                  from /git/arm-soc/include/linux/module.h:10,
>                  from /git/arm-soc/drivers/net/phy/smsc.c:20:
> In function 'memcpy',
>     inlined from 'smsc_get_strings' at /git/arm-soc/drivers/net/phy/smsc.c:166:3:
> /git/arm-soc/include/linux/string.h:309:4: error: call to '__read_overflow2' declared with attribute error: detected read beyond size of object passed as 2nd parameter
> 
> Using strncpy instead of memcpy should do the right thing here.
> 
> Fixes: 030a89028db0 ("net: phy: smsc: Implement PHY statistics")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

APplied to net-next, thanks Arnd.
