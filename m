From: David Miller <davem@davemloft.net>
Subject: Re: randconfig build error with next-20140502, in
 drivers/net/hyperv/netvsc_drv.c
Date: Fri, 02 May 2014 15:19:27 -0400 (EDT)
Message-ID: <20140502.151927.359156056899842119.davem@davemloft.net>
References: <CA+r1ZhhAdRwEFE3u4E1QQiCSa6Cz5Onhy1iVJHhzB4dUiEOL4g@mail.gmail.com>
 <91a4eac99889460f91f619385208cbca@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-next@vger.kernel.org, jim.epost@gmail.com, devel@linuxdriverproject.org
To: haiyangz@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <91a4eac99889460f91f619385208cbca@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Fri, 2 May 2014 14:42:06 +0000

> real_num_rx_queues is defined in "include/linux/netdevice.h":
> It requires CONFIG_SYSFS flag, which is enabled by default, but not set in 
> your config file.
> 
> Could you use default config and add hyperv drivers, then try again?

You must fix your driver to compile successfully under all possible
configuration combinations, not just the ones which are convenient
for you to support.
