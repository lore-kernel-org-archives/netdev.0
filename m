From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] can: ti_hecc: Fix unintialized variable
Date: Fri, 26 Aug 2011 12:51:07 -0400 (EDT)
Message-ID: <20110826.125107.163718127055087168.davem@davemloft.net>
References: <1314104748-16424-1-git-send-email-abhilash.kv@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wg@grandegger.com,
	linux-kernel@vger.kernel.org, =linux-omap@vger.kernel.org
To: abhilash.kv@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1314104748-16424-1-git-send-email-abhilash.kv@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Abhilash K V <abhilash.kv@ti.com>
Date: Tue, 23 Aug 2011 18:35:48 +0530

> In ti_hecc_xmit(), local variable "data" is not initialized before
> being used.
> This initialization got inadvertently removed in the following patch:
> 
> 	can: Unify droping of invalid tx skbs and netdev stats
> 
> Acked-by: Anant Gole <anantgole@ti.com>
> Signed-off-by: Abhilash K V <abhilash.kv@ti.com>

Applied.
