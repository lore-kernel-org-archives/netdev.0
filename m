From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [PATCH 2/3] mvebu: 370 RD: Add support for the switch
Date: Thu, 6 Nov 2014 22:30:27 -0500
Message-ID: <20141107033027.GE3698@titan.lakedaemon.net>
References: <1415214121-29286-1-git-send-email-andrew@lunn.ch>
 <1415214121-29286-3-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux ARM <linux-arm-kernel@lists.infradead.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	tawfik@marvell.com, maxime.ripard@free-electrons.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mho-03-ewr.mailhop.org ([204.13.248.66]:59966 "EHLO
	mho-01-ewr.mailhop.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751051AbaKGDah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 22:30:37 -0500
Content-Disposition: inline
In-Reply-To: <1415214121-29286-3-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 05, 2014 at 08:02:00PM +0100, Andrew Lunn wrote:
> The 370 rd has a 7 port, mv88E6182 switch, connected to eth1.  Add a
> fixed-link subnode to the ethernet device tree node, to force
> gigabit/full duplex.  Add a dsa node, with describing the four used
> ports. This requires adding an alias to the mdio node, so it can be
> referenced as a phandle.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---
>  arch/arm/boot/dts/armada-370-rd.dts  | 49 ++++++++++++++++++++++++++++++++----
>  arch/arm/boot/dts/armada-370-xp.dtsi |  2 +-
>  2 files changed, 45 insertions(+), 6 deletions(-)

Applied to mvebu/dt

thx,

Jason.
