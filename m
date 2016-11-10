From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mii: report 0 for unknown lp_advertising
Date: Wed, 09 Nov 2016 20:27:22 -0500 (EST)
Message-ID: <20161109.202722.2270232582216800896.davem@davemloft.net>
References: <20161108133232.1571441-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tremyfr@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161108133232.1571441-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue,  8 Nov 2016 14:31:38 +0100

> The newly introduced mii_ethtool_get_link_ksettings function sets
> lp_advertising to an uninitialized value when BMCR_ANENABLE is not
> set:
> 
> drivers/net/mii.c: In function 'mii_ethtool_get_link_ksettings':
> drivers/net/mii.c:224:2: error: 'lp_advertising' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> 
> As documented in include/uapi/linux/ethtool.h, the value is
> expected to be zero when we don't know it, so let's initialize
> it to that.
> 
> Fixes: bc8ee596afe8 ("net: mii: add generic function to support ksetting support")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
