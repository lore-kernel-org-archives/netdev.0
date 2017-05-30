From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: Add missing static to stub
 functions
Date: Tue, 30 May 2017 14:08:11 -0400 (EDT)
Message-ID: <20170530.140811.495484137447763709.davem@davemloft.net>
References: <20170529125612.110244-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54260 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750821AbdE3SIN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 14:08:13 -0400
In-Reply-To: <20170529125612.110244-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 29 May 2017 14:56:01 +0200

> 'static' was not enough, the helpers must be 'static inline'
> 
> net/dsa/mv88e6xxx/global2.h:123:12: error: 'mv88e6xxx_g2_misc_4_bit_port' defined but not used [-Werror=unused-function]
> net/dsa/mv88e6xxx/global2.h:117:12: error: 'mv88e6xxx_g2_pvt_write' defined but not used [-Werror=unused-function]
> 
> Fixes: c21fbe29f858 ("net: dsa: mv88e6xxx: Add missing static to stub functions")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
