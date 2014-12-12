From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: export fixed_phy_register()
Date: Fri, 12 Dec 2014 11:01:12 -0500 (EST)
Message-ID: <20141212.110112.2111858437852858965.davem@davemloft.net>
References: <1418357006-2450-1-git-send-email-msalter@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: msalter@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1418357006-2450-1-git-send-email-msalter@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mark Salter <msalter@redhat.com>
Date: Thu, 11 Dec 2014 23:03:26 -0500

> When building the bcmgenet driver as module, I get:
> 
> ERROR: "fixed_phy_register" [drivers/net/ethernet/broadcom/genet/genet.ko] undefined!
> 
> commit b0ba512e225d72 ("net: bcmgenet: enable driver to work without device
> tree") which added a call to fixed_phy_register. But fixed_phy_register
> needs to be exported if used from a module.
> 
> Signed-off-by: Mark Salter <msalter@redhat.com>

APplied.
