From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: turn carrier off on phy attach
Date: Fri, 15 Jan 2016 14:50:03 -0500 (EST)
Message-ID: <20160115.145003.183831730517733849.davem@davemloft.net>
References: <1452805038-27178-1-git-send-email-sjoerd.simons@collabora.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
	linux-kernel@vger.kernel.org, f.fainelli@gmail.com
To: sjoerd.simons@collabora.co.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452805038-27178-1-git-send-email-sjoerd.simons@collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sjoerd Simons <sjoerd.simons@collabora.co.uk>
Date: Thu, 14 Jan 2016 21:57:18 +0100

> The operstate of a networking device initially IF_OPER_UNKNOWN aka
> "unknown", updated on carrier state changes (with carrier state being on
> by default). This means it will stay unknown unless the carrier state
> goes to off at some point, which is not the case if the phy is already
> up/connected at startup.
> 
> Explicitly turn off the carrier on phy attach, leaving the phy state
> machine to turn the carrier on when it has done the initial negotiation.
> 
> Signed-off-by: Sjoerd Simons <sjoerd.simons@collabora.co.uk>

Applied, thank you.
