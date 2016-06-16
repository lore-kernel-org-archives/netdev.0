From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mdio: mux: avoid 'maybe-uninitialized' warning
Date: Wed, 15 Jun 2016 20:49:19 -0700 (PDT)
Message-ID: <20160615.204919.728147597242559549.davem@davemloft.net>
References: <1465898632-2248093-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, andrew@lunn.ch, pramod.kumar@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465898632-2248093-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 14 Jun 2016 12:03:17 +0200

> The latest changes to the MDIO code introduced a false-positive
> warning with gcc-6 (possibly others):
> 
> drivers/net/phy/mdio-mux.c: In function 'mdio_mux_init':
> drivers/net/phy/mdio-mux.c:188:3: error: 'parent_bus_node' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> 
> It's easy to avoid the warning by making sure the parent_bus_node
> is initialized in both cases at the start of the function, since
> the later 'of_node_put()' call is also valid for a NULL pointer
> argument.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: f20e6657a875 ("mdio: mux: Enhanced MDIO mux framework for integrated multiplexers")

Applied.
