From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH, net-next] qede: hide 32-bit compile warning
Date: Tue, 30 Aug 2016 23:35:45 -0700 (PDT)
Message-ID: <20160830.233545.1606889063995231548.davem@davemloft.net>
References: <20160826153808.838861-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@qlogic.com, Ariel.Elior@qlogic.com,
        everest-linux-l2@qlogic.com, sudarsana.kalluru@qlogic.com,
        manish.chopra@qlogic.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160826153808.838861-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 26 Aug 2016 17:37:53 +0200

> The addition of the per-queue statistics introduced a harmless warning
> on all 32-bit architectures:
> 
> drivers/net/ethernet/qlogic/qede/qede_ethtool.c: In function 'qede_get_ethtool_stats':
> drivers/net/ethernet/qlogic/qede/qede_ethtool.c:244:31: error: cast from pointer to integer of different size [-Werror=pointer-to-int-cast]
>       buf[cnt++] = QEDE_TQSTATS_DATA(edev,
>                                ^
> drivers/net/ethernet/qlogic/qede/qede_ethtool.c:244:22: error: cast to pointer from integer of different size [-Werror=int-to-pointer-cast]
>       buf[cnt++] = QEDE_TQSTATS_DATA(edev,
>                       ^
> This changes the cast to 'void *' to shut up the warning, which
> avoids the assumptions on the size of the pointer type.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 68db9ec2df07 ("qede: Add support for per-queue stats.")

Applied, thanks.
