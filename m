From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: Add missing static to stub functions
Date: Mon, 29 May 2017 11:01:41 -0400
Message-ID: <87efv7hfl6.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170529125612.110244-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>, Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170529125612.110244-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Arnd,

Arnd Bergmann <arnd@arndb.de> writes:

> 'static' was not enough, the helpers must be 'static inline'
>
> net/dsa/mv88e6xxx/global2.h:123:12: error: 'mv88e6xxx_g2_misc_4_bit_port' defined but not used [-Werror=unused-function]
> net/dsa/mv88e6xxx/global2.h:117:12: error: 'mv88e6xxx_g2_pvt_write' defined but not used [-Werror=unused-function]
>
> Fixes: c21fbe29f858 ("net: dsa: mv88e6xxx: Add missing static to stub functions")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Thanks,

        Vivien
