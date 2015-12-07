From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] PHY: DP83867: Remove looking in parent device
 for OF properties
Date: Sun, 06 Dec 2015 23:06:25 -0500 (EST)
Message-ID: <20151206.230625.1616451581601651391.davem@davemloft.net>
References: <1449459538-24105-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35092 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755244AbbLGEG1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Dec 2015 23:06:27 -0500
In-Reply-To: <1449459538-24105-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Mon,  7 Dec 2015 04:38:58 +0100

> Device tree properties for a phy device are expected to be in the phy
> node. The current code for the DP83867 also tries to look in the
> parent node. The devices binding documentation does not mention this,
> no current device tree file makes use of this, and it is not behaviour
> we want. So remove looking in the parent device.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Applied, thanks.
