From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] batman-adv: Revert "use core MTU range checking in
 misc drivers"
Date: Wed, 26 Oct 2016 17:20:14 -0400 (EDT)
Message-ID: <20161026.172014.1445485460255687424.davem@davemloft.net>
References: <20161022074624.30033-1-sven@narfation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        linux-kernel@vger.kernel.org, jarod@redhat.com
To: sven@narfation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161022074624.30033-1-sven@narfation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sven Eckelmann <sven@narfation.org>
Date: Sat, 22 Oct 2016 09:46:24 +0200

> The maximum MTU is defined via the slave devices of an batman-adv
> interface. Thus it is not possible to calculate the max_mtu during the
> creation of the batman-adv device when no slave devices are attached. Doing
> so would for example break non-fragmentation setups which then
> (incorrectly) allow an MTU of 1500 even when underlying device cannot
> transport 1500 bytes + batman-adv headers.
> 
> Checking the dynamically calculated max_mtu via the minimum of the slave
> devices MTU during .ndo_change_mtu is also used by the bridge interface.
> 
> Cc: Jarod Wilson <jarod@redhat.com>
> Fixes: b3e3893e1253 ("net: use core MTU range checking in misc drivers")
> Signed-off-by: Sven Eckelmann <sven@narfation.org>

Applied, thanks.
