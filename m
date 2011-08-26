From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] can: ti_hecc: Fix uninitialized spinlock in probe
Date: Fri, 26 Aug 2011 12:51:02 -0400 (EDT)
Message-ID: <20110826.125102.1570625678673055416.davem@davemloft.net>
References: <1314104757-16462-1-git-send-email-abhilash.kv@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wg@grandegger.com,
	linux-kernel@vger.kernel.org, =linux-omap@vger.kernel.org
To: abhilash.kv@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1314104757-16462-1-git-send-email-abhilash.kv@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Abhilash K V <abhilash.kv@ti.com>
Date: Tue, 23 Aug 2011 18:35:57 +0530

> In ti_hecc_probe(), the spinlock  priv->mbx_lock is not
> inited, causing a spinlock lockup BUG.
> 
> Acked-by: Anant Gole <anantgole@ti.com>
> Signed-off-by: Abhilash K V <abhilash.kv@ti.com>

Applied.
