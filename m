From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] driver/net: add missing rtnl lock/unlock for benet
Date: Tue, 15 Apr 2014 15:09:50 -0400 (EDT)
Message-ID: <20140415.150950.2105729446204659132.davem@davemloft.net>
References: <1397544352-28841-1-git-send-email-zhen-hual@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: zhen-hual@hp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1397544352-28841-1-git-send-email-zhen-hual@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Li, Zhen-Hua" <zhen-hual@hp.com>
Date: Tue, 15 Apr 2014 14:45:52 +0800

> From: "Li, Zhen-Hua" <zhen-hual@hp.com>
> 
> In benet driver, netif_device_detach and netif_device_attach should be
> called between rtnl_lock and rtnl_unlock.
> 
> Signed-off-by: Li, Zhen-Hua <zhen-hual@hp.com>

This absolutely does not look like a driver specific issue, therefore
I do not want you to make such locking context adjustments only in
your driver.

Do it somewhere generic so that every driver gets the fix, not just
your driver.
