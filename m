From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netcp: fix typo in netcp_setup_tc
Date: Mon, 22 Feb 2016 15:52:21 -0500 (EST)
Message-ID: <20160222.155221.1930653393972032546.davem@davemloft.net>
References: <1456174246-293822-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, john.r.fastabend@intel.com,
	netdev@vger.kernel.org, w-kwok2@ti.com, m-karicheri2@ti.com,
	linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456174246-293822-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 22 Feb 2016 21:50:39 +0100

> A change to the prototype of netcp_setup_tc() missed a '*'
> character, which broke compilation of hte netcp driver:
> 
> drivers/net/ethernet/ti/netcp_core.c: In function 'netcp_setup_tc':
> drivers/net/ethernet/ti/netcp_core.c:1839:31: error: invalid type argument of '->' (have 'struct tc_to_netdev')
> drivers/net/ethernet/ti/netcp_core.c:1872:19: error: initialization from incompatible pointer type [-Werror=incompatible-pointer-types]
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 16e5cc647173 ("net: rework setup_tc ndo op to consume general tc operand")

Should be fixed in my net-next tree already.

Thanks.
