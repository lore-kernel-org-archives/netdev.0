From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 4/6] tg3: Add reset_phy parameter to chip reset
 functions
Date: Sat, 29 Apr 2006 18:59:52 -0700 (PDT)
Message-ID: <20060429.185952.101410162.davem@davemloft.net>
References: <1146267368.4780.17.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:18885
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750870AbWD3B7g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Apr 2006 21:59:36 -0400
To: mchan@broadcom.com
In-Reply-To: <1146267368.4780.17.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 28 Apr 2006 16:36:08 -0700

> Add a reset_phy parameter to tg3_reset_hw() and tg3_init_hw(). With
> the full chip reset during MAC address change, the automatic PHY reset
> during chip reset will cause a link down and bonding will not work
> properly as a result. With this reset_phy parameter, we can do a chip
> reset without link down when changing MAC address or MTU.
> 
> Signed-off-by: Gary Zambrano <zambrano@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.

Doesn't the signalling interface between the MAC and the
PHY get reset during a chip reset and couldn't that cause
problems if we bypass the PHY reset?

Thanks.
