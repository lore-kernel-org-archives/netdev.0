From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH 1/1] drivers: net: cpsw: fix multicast flush in
 dual emac mode
Date: Tue, 13 Jan 2015 16:54:37 -0500 (EST)
Message-ID: <20150113.165437.419101854292412908.davem@davemloft.net>
References: <1421150749-4329-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@vger.kernel.org
To: mugunthanvnm@ti.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1421150749-4329-1-git-send-email-mugunthanvnm@ti.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Tue, 13 Jan 2015 17:35:49 +0530

> Since ALE table is a common resource for both the interfaces in Dual EMAC
> mode and while bringing up the second interface in cpsw_ndo_set_rx_mode()
> all the multicast entries added by the first interface is flushed out and
> only second interface multicast addresses are added. Fixing this by
> flushing multicast addresses based on dual EMAC port vlans which will not
> affect the other emac port multicast addresses.
> 
> Fixes: d9ba8f9 (driver: net: ethernet: cpsw: dual emac interface implementation)
> Cc: <stable@vger.kernel.org> # v3.9+
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>

Applied, thanks.
