From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3] net: xgene: avoid bogus
 maybe-uninitialized warning
Date: Thu, 08 Dec 2016 21:31:16 -0500 (EST)
Message-ID: <20161208.213116.355037793343857244.davem@davemloft.net>
References: <20161208215727.44841-1-arnd@arndb.de>
        <20161208215727.44841-3-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isubramanian@apm.com, kchudgar@apm.com, qnguyen@apm.com,
        kdinh@apm.com, toanle@apm.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161208215727.44841-3-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Thu,  8 Dec 2016 22:57:05 +0100

> In some configurations, gcc cannot trace the state of variables
> across a spin_unlock() barrier, leading to a warning about
> correct code:
> 
> xgene_enet_main.c: In function 'xgene_enet_start_xmit':
> ../../../phy/mdio-xgene.h:112:14: error: 'mss_index' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> 
> Here we can trivially move the assignment before that spin_unlock,
> which reliably avoids the warning.
> 
> Fixes: e3978673f514 ("drivers: net: xgene: Fix MSS programming")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
