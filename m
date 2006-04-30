From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 1/6] tg3: Call netif_carrier_off() during phy reset
Date: Sat, 29 Apr 2006 18:55:58 -0700 (PDT)
Message-ID: <20060429.185558.40930722.davem@davemloft.net>
References: <1146267307.4780.14.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:59618
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750857AbWD3Bzr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Apr 2006 21:55:47 -0400
To: mchan@broadcom.com
In-Reply-To: <1146267307.4780.14.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 28 Apr 2006 16:35:06 -0700

> Add netif_carrier_off() call during tg3_phy_reset(). This is needed
> to properly track the netif_carrier state in cases where we do a
> PHY reset with interrupts disabled. The SerDes code will not run
> properly if the netif_carrier state is wrong.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks.
