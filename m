From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: tilegx: use correct timespec64 type
Date: Fri, 17 Jun 2016 22:27:48 -0700 (PDT)
Message-ID: <20160617.222748.1590468596344698496.davem@davemloft.net>
References: <20160617161540.1362545-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cmetcalf@mellanox.com, y2038@lists.linaro.org,
	richardcochran@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160617161540.1362545-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 17 Jun 2016 18:15:30 +0200

> The conversion to the 64-bit time based ptp methods left two instances
> of 'struct timespec' in place. This is harmless because 64-bit
> architectures define timespec64 as timespec, and this driver is
> not used on 32-bit machines.
> 
> However, using 'struct timespec64' directly is obviously the right
> thing to do, and will help us remove 'struct timespec' in the future.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: b9acf24f779c ("ptp: tilegx: convert to the 64 bit get/set time methods.")

Applied, thanks.
