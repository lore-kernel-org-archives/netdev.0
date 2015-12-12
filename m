From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] netcp: add more __le32 annotations
Date: Fri, 11 Dec 2015 19:35:03 -0500 (EST)
Message-ID: <20151211.193503.312733505035879098.davem@davemloft.net>
References: <1578620.t1ANcREMZ8@wuerfel>
	<6435706.peaM34LhnV@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: w-kwok2@ti.com, netdev@vger.kernel.org, m-karicheri2@ti.com,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: arnd@arndb.de
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <6435706.peaM34LhnV@wuerfel>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 08 Dec 2015 16:32:59 +0100

> The handling of epib and psdata remains a bit unclear in the driver,
> as we access the same fields both as CPU-endian and through DMA
> from the device.
> 
> Sparse warns about this:
> ti/netcp_core.c:1147:21: warning: incorrect type in assignment (different base types)
> ti/netcp_core.c:1147:21:    expected unsigned int [usertype] *[assigned] epib
> ti/netcp_core.c:1147:21:    got restricted __le32 *<noident>
> 
> This uses __le32 types in a few places and uses __force where the code
> looks fishy. The previous patch should really have produced the correct
> behavior, but this second patch is needed to shut up the warnings about
> it. Ideally it would be slightly rewritten to not need those casts,
> but I don't dare do that without access to the hardware for proper
> testing.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied to net-next.
