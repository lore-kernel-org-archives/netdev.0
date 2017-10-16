From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [net-next] net: systemport: add NET_DSA dependency
Date: Mon, 16 Oct 2017 21:21:26 +0100 (WEST)
Message-ID: <20171016.212126.2225476616318738346.davem@davemloft.net>
References: <20171016113258.3735473-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, michael.chan@broadcom.com,
        sathya.perla@broadcom.com, nicolas.pitre@linaro.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171016113258.3735473-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 16 Oct 2017 13:32:36 +0200

> The notifier cause a link error when NET_DSA is a loadable
> module:
> 
> drivers/net/ethernet/broadcom/bcmsysport.o: In function `bcm_sysport_remove':
> bcmsysport.c:(.text+0x1582): undefined reference to `unregister_dsa_notifier'
> drivers/net/ethernet/broadcom/bcmsysport.o: In function `bcm_sysport_probe':
> bcmsysport.c:(.text+0x278d): undefined reference to `register_dsa_notifier'
> 
> This adds a dependency that forces the systemport driver to be
> a loadable module as well when that happens, but otherwise
> allows it to be built normally when DSA is either built-in or
> completely disabled.
> 
> Fixes: d156576362c0 ("net: systemport: Establish lower/upper queue mapping")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied, thank you.
