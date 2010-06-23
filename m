From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: enable rx/tx in sky2_phy_reinit()
Date: Wed, 23 Jun 2010 14:37:47 -0700 (PDT)
Message-ID: <20100623.143747.260104620.davem@davemloft.net>
References: <20100617022158.GA4135@jenkins.ifup.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: brandon@ifup.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38367
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752713Ab0FWVhg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jun 2010 17:37:36 -0400
In-Reply-To: <20100617022158.GA4135@jenkins.ifup.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brandon Philips <brandon@ifup.org>
Date: Wed, 16 Jun 2010 19:21:58 -0700

> sky2_phy_reinit is called by the ethtool helpers sky2_set_settings,
> sky2_nway_reset and sky2_set_pauseparam when netif_running.
> 
> However, at the end of sky2_phy_init GM_GP_CTRL has GM_GPCR_RX_ENA and
> GM_GPCR_TX_ENA cleared. So, doing these commands causes the device to
> stop working:
> 
> $ ethtool -r eth0
> $ ethtool -A eth0 autoneg off
> 
> Fix this issue by enabling Rx/Tx after running sky2_phy_init in
> sky2_phy_reinit.
> 
> Signed-off-by: Brandon Philips <bphilips@suse.de>
> Tested-by: Brandon Philips <bphilips@suse.de>
> Cc: stable@kernel.org

Applied, thanks for fixing this bug.
