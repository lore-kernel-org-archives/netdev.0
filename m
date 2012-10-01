From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: ti cpsw ethernet: set IFCTL_A bit in MACCONTROL
Date: Mon, 01 Oct 2012 17:09:36 -0400 (EDT)
Message-ID: <20121001.170936.2247130739630040000.davem@davemloft.net>
References: <1348773574-30318-1-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mugunthanvnm@ti.com, hvaibhav@ti.com
To: zonque@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41159 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932220Ab2JAVJj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 17:09:39 -0400
In-Reply-To: <1348773574-30318-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Mack <zonque@gmail.com>
Date: Thu, 27 Sep 2012 21:19:34 +0200

> For RMII/RGMII mode operation in 100Mbps, the CPSW needs to set the
> IFCTL_A bits in the MACCONTROL register. For all other PHY modes, this
> bit is unused, so setting it unconditionally shouldn't cause any
> trouble.
> 
> Signed-off-by: Daniel Mack <zonque@gmail.com>

Applied.
