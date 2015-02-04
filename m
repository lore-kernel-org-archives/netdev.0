From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fs_enet: Implement NETIF_F_SG feature
Date: Wed, 04 Feb 2015 13:13:20 -0800 (PST)
Message-ID: <20150204.131320.2283837573385701111.davem@davemloft.net>
References: <20150202170654.D5EE21A5E90@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pantelis.antoniou@gmail.com, vbordug@ru.mvista.com,
	linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org
To: christophe.leroy@c-s.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150202170654.D5EE21A5E90@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christophe Leroy <christophe.leroy@c-s.fr>
Date: Mon,  2 Feb 2015 18:06:54 +0100 (CET)

> Freescale ethernet controllers have the capability to re-assemble fragmented
> data into a single ethernet frame. This patch uses this capability and
> implements NETIP_F_SG feature into the fs_enet ethernet driver.
> 
> On a MPC885, I get 53% performance improvement on a ftp transfer of a 15Mb file:
>   * Without the patch : 2,8 Mbps
>   * With the patch : 4,3 Mbps
> 
> Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>

Applied, thanks.
