From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] [net-next] net: systemport: add NET_DSA dependency
Date: Mon, 16 Oct 2017 10:55:05 -0700
Message-ID: <ef4033cb-3b0e-ed9b-bdd4-7cb40a432714@gmail.com>
References: <20171016113258.3735473-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Michael Chan <michael.chan@broadcom.com>,
        Sathya Perla <sathya.perla@broadcom.com>,
        Nicolas Pitre <nicolas.pitre@linaro.org>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171016113258.3735473-1-arnd@arndb.de>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/16/2017 04:32 AM, Arnd Bergmann wrote:
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

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

Thanks Arnd.
-- 
Florian
