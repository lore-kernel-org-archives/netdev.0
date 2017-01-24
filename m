From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phy: marvell: remove conflicting initializer
Date: Tue, 24 Jan 2017 14:09:24 -0500 (EST)
Message-ID: <20170124.140924.1432554530568021817.davem@davemloft.net>
References: <20170123121905.3245589-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, andrew@lunn.ch,
        charles-antoine.couret@nexvision.fr, clemens.gruber@pqgruber.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170123121905.3245589-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 23 Jan 2017 13:18:41 +0100

> One line was apparently pasted incorrectly during a new feature patch:
> 
> drivers/net/phy/marvell.c:2090:15: error: initialized field overwritten [-Werror=override-init]
>    .features = PHY_GBIT_FEATURES,
> 
> I'm removing the extraneous line here to avoid the W=1 warning and restore
> the previous flags value, and I'm slightly reordering the lines for consistency
> to make it less likely to happen again in the future. The ordering in the
> array is still not the same as in the structure definition, instead I picked
> the order that is most common in this file and that seems to make more sense
> here.
> 
> Fixes: 0b04680fdae4 ("phy: marvell: Add support for temperature sensor")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied, thanks Arnd.

Please start putting appropriate "net" and "net-next" strings in your
PATCH subject lines, it will save me a lot of time.
