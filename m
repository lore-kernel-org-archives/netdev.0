From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [net] liquidio: fix timespec64_to_ns typo
Date: Fri, 13 Oct 2017 10:19:06 -0700 (PDT)
Message-ID: <20171013.101906.1329879506895069911.davem@davemloft.net>
References: <20171012094841.3178599-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: derek.chickles@caviumnetworks.com,
        satananda.burla@caviumnetworks.com,
        felix.manlunas@caviumnetworks.com,
        raghu.vatsavayi@caviumnetworks.com, intiyaz.basha@cavium.com,
        ricardo.farrington@cavium.com, veerasenareddy.burru@cavium.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171012094841.3178599-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 12 Oct 2017 11:48:31 +0200

> While experimenting with changes to the timekeeping code, I
> ran into a build error in the liquidio driver:
> 
> drivers/net/ethernet/cavium/liquidio/lio_main.c: In function 'liquidio_ptp_settime':
> drivers/net/ethernet/cavium/liquidio/lio_main.c:1850:22: error: passing argument 1 of 'timespec_to_ns' from incompatible pointer type [-Werror=incompatible-pointer-types]
> 
> The driver had a type mismatch since it was first merged, but
> this never caused problems because it is only built on 64-bit
> architectures that define timespec and timespec64 to the same
> type.
> 
> If we ever want to compile-test the driver on 32-bit or change
> the way that 64-bit timespec64 is defined, we need to fix it,
> so let's just do it now.
> 
> Fixes: f21fb3ed364b ("Add support of Cavium Liquidio ethernet adapters")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
