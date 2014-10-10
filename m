From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fs_enet: error: 'SCCE_ENET_TXF' undeclared
Date: Fri, 10 Oct 2014 00:51:46 -0400 (EDT)
Message-ID: <20141010.005146.105821454500503183.davem@davemloft.net>
References: <20141009145443.74AD61AB275@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pantelis.antoniou@gmail.com, vbordug@ru.mvista.com,
	linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org
To: christophe.leroy@c-s.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141009145443.74AD61AB275@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christophe Leroy <christophe.leroy@c-s.fr>
Date: Thu,  9 Oct 2014 16:54:43 +0200 (CEST)

> [linux-devel:devel-hourly-2014100909 3763/3915] drivers/net/ethernet/freescale/fs_enet/mac-scc.c:119:32: error: 'SCCE_ENET_TXF' undeclared
> 
> Due to patch d43a396 net: fs_enet: Add NAPI TX, it appears that some target
> compilations are broken.
> This is due to the fact that unlike the FEC, the SCC and FCC don't have a TXF
> event (complete Frame transmitted) but only TXB (buffer transmitted).
> 
> Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>

Applied, thanks.
