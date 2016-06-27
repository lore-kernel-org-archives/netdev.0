From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dsa: mv88e6xxx: hide unused functions
Date: Mon, 27 Jun 2016 10:43:36 -0400 (EDT)
Message-ID: <20160627.104336.460514363808844247.davem@davemloft.net>
References: <20160623141409.356324-1-arnd@arndb.de>
	<87fus4x760.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, andrew@lunn.ch, f.fainelli@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87fus4x760.fsf@ketchup.mtl.sfl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Thu, 23 Jun 2016 11:21:27 -0400

> Hi,
> 
> Arnd Bergmann <arnd@arndb.de> writes:
> 
>> When CONFIG_NET_DSA_HWMON is disabled, we get warnings about two unused
>> functions whose only callers are all inside of an #ifdef:
>>
>> drivers/net/dsa/mv88e6xxx.c:3257:12: 'mv88e6xxx_mdio_page_write' defined but not used [-Werror=unused-function]
>> drivers/net/dsa/mv88e6xxx.c:3244:12: 'mv88e6xxx_mdio_page_read' defined but not used [-Werror=unused-function]
>>
>> This adds another ifdef around the function definitions. The warnings
>> appeared after the functions were marked 'static', but the problem
>> was already there before that.
>>
>> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>> Fixes: 57d3231057e9 ("net: dsa: mv88e6xxx: fix style issues")
> 
> Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> 
> David, this patch is meant for net-next. It applies cleanly *before* my
> last two submissions:
> 
>     1/2 http://patchwork.ozlabs.org/patch/638773/
>     2/2 http://patchwork.ozlabs.org/patch/638772/

Oops, I applied those already.

Arnd, please respin if necessary.
