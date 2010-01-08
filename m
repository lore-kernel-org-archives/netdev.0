From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TI DaVinci EMAC: Handle emac module clock correctly.
Date: Thu, 07 Jan 2010 17:28:06 -0800 (PST)
Message-ID: <20100107.172806.37586885.davem@davemloft.net>
References: <1262859757-2809-1-git-send-email-srk@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com
To: srk@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35009
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752315Ab0AHB15 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 20:27:57 -0500
In-Reply-To: <1262859757-2809-1-git-send-email-srk@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sriramakrishnan <srk@ti.com>
Date: Thu,  7 Jan 2010 15:52:37 +0530

> In the driver probe function the emac module clock needs to
> be enabled before calling register_netdev(). As soon as the
> device is registered the driver get_stats function can be invoked
> by the core - the module clock must be switched on to be able to
> read from stats registers. Also explicitly call matching clk_disable
> for failure conditions in probe function.
> 
> Signed-off-by: Sriramakrishnan <srk@ti.com>

Applied.
