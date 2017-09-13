From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] w90p910_ether: include linux/interrupt.h
Date: Tue, 12 Sep 2017 20:59:47 -0700 (PDT)
Message-ID: <20170912.205947.2162006850051360659.davem@davemloft.net>
References: <20170912123227.3418786-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcuos.com@gmail.com, linux-arm-kernel@lists.infradead.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170912123227.3418786-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 12 Sep 2017 14:31:48 +0200

> A randconfig build caused a compile failure:
> 
> drivers/net/ethernet/nuvoton/w90p910_ether.c: In function 'w90p910_ether_close':
> drivers/net/ethernet/nuvoton/w90p910_ether.c:580:2: error: implicit declaration of function 'free_irq'; did you mean 'free_uid'? [-Werror=implicit-function-declaration]
> 
> Adding the correct include fixes the problem.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
