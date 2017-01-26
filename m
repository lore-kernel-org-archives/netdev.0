From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [net-next] bridge: move maybe_deliver_addr() inside
 #ifdef
Date: Wed, 25 Jan 2017 23:16:25 -0500 (EST)
Message-ID: <20170125.231625.778055316669261176.davem@davemloft.net>
References: <20170125222950.1352566-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, linus.luessing@c0d3.blue,
        nikolay@cumulusnetworks.com, nbd@nbd.name,
        bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170125222950.1352566-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 25 Jan 2017 23:29:33 +0100

> The only caller of this new function is inside of an #ifdef checking
> for CONFIG_BRIDGE_IGMP_SNOOPING, so we should move the implementation
> there too, in order to avoid this harmless warning:
> 
> net/bridge/br_forward.c:177:13: error: 'maybe_deliver_addr' defined but not used [-Werror=unused-function]
> 
> Fixes: 6db6f0eae605 ("bridge: multicast to unicast")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied, thank you.
