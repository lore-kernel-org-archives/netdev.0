From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net, ucc_geth: ethtool -d shows phy register values
Date: Sat, 26 Jun 2010 21:20:33 -0700 (PDT)
Message-ID: <20100626.212033.135523015.davem@davemloft.net>
References: <1276610603-11589-1-git-send-email-holger.brunck@keymile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, christopher.varlese@keymile.com,
	leoli@freescale.com, avorontsov@ru.mvista.com, tj@kernel.org
To: holger.brunck@keymile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55049
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750903Ab0F0EUW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jun 2010 00:20:22 -0400
In-Reply-To: <1276610603-11589-1-git-send-email-holger.brunck@keymile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Holger Brunck <holger.brunck@keymile.com>
Date: Tue, 15 Jun 2010 16:03:23 +0200

> From: Chris Varlese <christopher.varlese@keymile.com>
> 
> Fixes MPC83xx UCC Ethernet driver so ethtool -d dumps values of
> the PHY registers (like other devices do) instead of the UCC registers
> of the MPC83xx.
> 
> Signed-off-by: Chris Varlese <christopher.varlese@keymile.com>
> Signed-off-by: Holger Brunck <holger.brunck@keymile.com>

This doesn't look right at all.

ethtool -d dumps "chip registers", not the PHY registers.  So the
current code looks correct, not what you're changing it to.
