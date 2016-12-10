From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: mvneta: select GENERIC_ALLOCATOR
Date: Sat, 10 Dec 2016 17:28:17 -0500 (EST)
Message-ID: <20161210.172817.1464401745620815425.davem@davemloft.net>
References: <20161210103844.1465583-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregory.clement@free-electrons.com, mw@semihalf.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161210103844.1465583-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Sat, 10 Dec 2016 11:38:32 +0100

> We previously relied on GENERIC_ALLOCATOR to be selected by CONFIG_ARM,
> but now we can compile-test the driver on other architectures that
> don't select it:
> 
> drivers/net/built-in.o: In function `mvneta_bm_remove':
> mvneta_bm.c:(.text+0x4ee35): undefined reference to `gen_pool_free'
> 
> This adds an explicit select for the part of the driver that has
> the dependency.
> 
> Fixes: a0627f776a45 ("net: marvell: Allow drivers to be built with COMPILE_TEST")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
