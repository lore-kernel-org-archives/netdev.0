From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] net: netcp: ethss: fix errors in ethtool ops
Date: Tue, 20 Dec 2016 14:08:09 -0500 (EST)
Message-ID: <20161220.140809.1106859712498296957.davem@davemloft.net>
References: <1482188157-24490-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: m-karicheri2@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1482188157-24490-1-git-send-email-m-karicheri2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Murali Karicheri <m-karicheri2@ti.com>
Date: Mon, 19 Dec 2016 17:55:56 -0500

> From: WingMan Kwok <w-kwok2@ti.com>
> 
> In ethtool ops, it needs to retrieve the corresponding
> ethss module (gbe or xgbe) from the net_device structure.
> Prior to this patch, the retrieving procedure only
> checks for the gbe module.  This patch fixes the issue
> by checking the xgbe module if the net_device structure
> does not correspond to the gbe module.
> 
> Signed-off-by: WingMan Kwok <w-kwok2@ti.com>
> Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
> Signed-off-by: Sekhar Nori <nsekhar@ti.com>

Applied.
