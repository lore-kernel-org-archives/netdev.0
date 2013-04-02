From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] Provide empty functions if OF_NET is not configured
Date: Tue, 02 Apr 2013 16:44:35 -0400 (EDT)
Message-ID: <20130402.164435.394488805917592019.davem@davemloft.net>
References: <1364931311-30603-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, grant.likely@secretlab.ca,
	rob.herring@calxeda.com, david.daney@cavium.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org
To: linux@roeck-us.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1364931311-30603-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guenter Roeck <linux@roeck-us.net>
Date: Tue,  2 Apr 2013 12:35:06 -0700

> Provide empty functions for of_get_phy_mode() and of_get_mac_address()
> if OF_NET is not configured. Modify affected drivers to rely on the
> now available functions.

All applied, but please post your patches against the appropriate
tree.

In net-next, fec.c has been renamed to fec_main.c so I had to adjust
your patch so that it would apply correctly.
