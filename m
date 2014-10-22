From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fs_enet: set back promiscuity mode after restart
Date: Wed, 22 Oct 2014 15:33:39 -0400 (EDT)
Message-ID: <20141022.153339.553009019191281217.davem@davemloft.net>
References: <20141022070547.83AAB1A5E63@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pantelis.antoniou@gmail.com, vbordug@ru.mvista.com,
	linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, germain.montoies@c-s.fr
To: christophe.leroy@c-s.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141022070547.83AAB1A5E63@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christophe Leroy <christophe.leroy@c-s.fr>
Date: Wed, 22 Oct 2014 09:05:47 +0200 (CEST)

> After interface restart (eg: after link disconnection/reconnection), the bridge
> function doesn't work anymore. This is due to the promiscuous mode being cleared
> by the restart.
> 
> The mac-fcc already includes code to set the promiscuous mode back during the restart.
> This patch adds the same handling to mac-fec and mac-scc.
> 
> Tested with bridge function on MPC885 with FEC.
> 
> Reported-by: Germain Montoies <germain.montoies@c-s.fr>
> Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>

Applied, thanks.
