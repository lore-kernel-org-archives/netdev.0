From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH] net: ethernet: davinci_emac: Fix devioctl while in fixed
 link
Date: Tue, 26 Apr 2016 11:37:30 +0530
Message-ID: <571F05A2.8070502@ti.com>
References: <1461606098-20057-1-git-send-email-narmstrong@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Brian Hutchinson <b.hutchman@gmail.com>
To: Neil Armstrong <narmstrong@baylibre.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Tom Lendacky <thomas.lendacky@amd.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:35809 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751847AbcDZGHr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Apr 2016 02:07:47 -0400
In-Reply-To: <1461606098-20057-1-git-send-email-narmstrong@baylibre.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 25 April 2016 11:11 PM, Neil Armstrong wrote:
> When configured in fixed link, the DaVinci emac driver sets the
> priv->phydev to NULL and further ioctl calls to the phy_mii_ioctl()
> causes the kernel to crash.
> 
> Cc: Brian Hutchinson <b.hutchman@gmail.com>
> Fixes: 1bb6aa56bb38 ("net: davinci_emac: Add support for fixed-link PHY")
> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>

Reviewed-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
