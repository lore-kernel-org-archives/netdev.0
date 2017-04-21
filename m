From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: remove unnecessary variable
 assignment
Date: Fri, 21 Apr 2017 13:26:23 -0400 (EDT)
Message-ID: <20170421.132623.1121578815628795379.davem@davemloft.net>
References: <20170419173109.3683437-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: derek.chickles@caviumnetworks.com,
        satananda.burla@caviumnetworks.com,
        felix.manlunas@caviumnetworks.com,
        raghu.vatsavayi@caviumnetworks.com, prasad.kanneganti@cavium.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170419173109.3683437-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 19 Apr 2017 19:30:59 +0200

> gcc points out an useless assignment that was added during code refactoring:
> 
> drivers/net/ethernet/cavium/liquidio/lio_ethtool.c: In function 'octnet_intrmod_callback':
> drivers/net/ethernet/cavium/liquidio/lio_ethtool.c:1315:59: error: parameter 'oct_dev' set but not used [-Werror=unused-but-set-parameter]
> 
> This is harmless but can clearly be remove to avoid the warning.
> 
> Fixes: 50c0add534d2 ("liquidio: refactor interrupt moderation code")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
