From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] phy dp83867: Fix compilation with
 CONFIG_OF_MDIO=m
Date: Tue, 17 May 2016 14:22:19 -0400 (EDT)
Message-ID: <20160517.142219.1941942174765442762.davem@davemloft.net>
References: <1463424763-58807-1-git-send-email-agraf@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	michal.simek@xilinx.com, dmurphy@ti.com, andrew@lunn.ch
To: agraf@suse.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463424763-58807-1-git-send-email-agraf@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Graf <agraf@suse.de>
Date: Mon, 16 May 2016 20:52:42 +0200

> When CONFIG_OF_MDIO is configured as module, the #define for it really
> is CONFIG_OF_MDIO_MODULE, not CONFIG_OF_MDIO. So if we are compiling it
> as module, the dp83867 doesn't see that OF_MDIO was selected and doesn't
> read the dt rgmii parameters.
> 
> The fix is simple: Use IS_ENABLED(). It checks for both - module as well
> as compiled in code.
> 
> Signed-off-by: Alexander Graf <agraf@suse.de>

Applied.
