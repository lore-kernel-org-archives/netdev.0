From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: Add missing static to stub functions
Date: Mon, 29 May 2017 17:30:30 +0200
Message-ID: <20170529153030.GB21315@lunn.ch>
References: <20170529125612.110244-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53638 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751039AbdE2Pam (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 29 May 2017 11:30:42 -0400
Content-Disposition: inline
In-Reply-To: <20170529125612.110244-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 29, 2017 at 02:56:01PM +0200, Arnd Bergmann wrote:
> 'static' was not enough, the helpers must be 'static inline'
> 
> net/dsa/mv88e6xxx/global2.h:123:12: error: 'mv88e6xxx_g2_misc_4_bit_port' defined but not used [-Werror=unused-function]
> net/dsa/mv88e6xxx/global2.h:117:12: error: 'mv88e6xxx_g2_pvt_write' defined but not used [-Werror=unused-function]
> 
> Fixes: c21fbe29f858 ("net: dsa: mv88e6xxx: Add missing static to stub functions")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Hi Arnd

Dave merged my fix yesterday.

     Andrew
