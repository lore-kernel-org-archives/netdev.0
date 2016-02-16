From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: dsa: remove phy_disconnect from error path
Date: Tue, 16 Feb 2016 16:05:33 -0500 (EST)
Message-ID: <20160216.160533.2078787779758209851.davem@davemloft.net>
References: <1455187489-30771-1-git-send-email-s.hauer@pengutronix.de>
	<1455187489-30771-2-git-send-email-s.hauer@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	andrew@lunn.ch, linux@roeck-us.net
To: s.hauer@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455187489-30771-2-git-send-email-s.hauer@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sascha Hauer <s.hauer@pengutronix.de>
Date: Thu, 11 Feb 2016 11:44:49 +0100

> The phy has not been initialized, disconnecting it in the error
> path results in a NULL pointer exception. Drop the phy_disconnect
> from the error path.
> 
> Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>

Applied.
