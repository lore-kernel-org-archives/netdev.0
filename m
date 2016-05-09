From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH V2 04/22] net-next: mediatek: properly handle RGMII modes
Date: Mon, 9 May 2016 14:09:01 +0200
Message-ID: <20160509120901.GS7972@lunn.ch>
References: <1462788254-40572-1-git-send-email-john@phrozen.org>
 <1462788254-40572-5-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, nbd@nbd.name, netdev@vger.kernel.org,
	linux-mediatek@lists.infradead.org
To: John Crispin <john@phrozen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59705 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751764AbcEIMJJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 08:09:09 -0400
Content-Disposition: inline
In-Reply-To: <1462788254-40572-5-git-send-email-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 09, 2016 at 12:03:56PM +0200, John Crispin wrote:
> If an external Gigabit PHY is connected to either of the MACs we need to
> be able to tell the PHY to use a delay. Not doing so will result in heavy
> packet loss and/or data corruption when using PHYs such as the IC+ IP1001.
> We tell the PHY which MII delay mode to use via the devictree.
> 
> The ethernet driver needs to be adapted to handle all 3 rgmii-*id modes
> in the same way as normal rgmii when setting up the MAC.
> 
> Signed-off-by: John Crispin <john@phrozen.org>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

	     Andrew
