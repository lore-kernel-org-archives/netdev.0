From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/1] drivers: net: cpsw: enable promiscuous
 mode support
Date: Tue, 21 Jan 2014 18:11:37 -0800 (PST)
Message-ID: <20140121.181137.840971123475894969.davem@davemloft.net>
References: <1390219718-31749-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-omap@vger.kernel.org
To: mugunthanvnm@ti.com
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1390219718-31749-1-git-send-email-mugunthanvnm@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Mon, 20 Jan 2014 17:38:38 +0530

> +		if (!enable && ((priv->slaves[0].ndev->flags & IFF_PROMISC) ||
> +				(priv->slaves[1].ndev->flags & IFF_PROMISC))) {

This assumption that there are exactly 2 slaves is not valid.

Use the appropriate for_each_slave() et al. abstractions to access
the slaves.
