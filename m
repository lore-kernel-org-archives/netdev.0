From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3.4-rc7 regression] net/bond: return int from
 recv_probe()
Date: Tue, 15 May 2012 13:07:38 -0400 (EDT)
Message-ID: <20120515.130738.2194422199621090259.davem@davemloft.net>
References: <20120512200901.811D37C0074@ra.kernel.org>
	<CAMuHMdVuDC7LiYuOdVELsxbbyf1PVZ-QvHY_7pUxigk+DWfysg@mail.gmail.com>
	<201205151056.53621.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: geert@linux-m68k.org, jbohac@suse.cz, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201205151056.53621.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 15 May 2012 10:56:53 +0000

> 13a8e0c8c "bonding: don't increase rx_dropped after processing LACPDUs"
> changed the prototype of the bonding recv_probe handler, but only in
> some places, as identified by this warning:
> 
> drivers/net/bonding/bond_main.c: In function 'bond_handle_frame':
> drivers/net/bonding/bond_main.c:1463:13: error: assignment from incompatible pointer type [-Werror]
> drivers/net/bonding/bond_main.c: In function 'bond_open':
> drivers/net/bonding/bond_main.c:3441:21: error: assignment from incompatible pointer type [-Werror]
> drivers/net/bonding/bond_main.c:3448:20: error: assignment from incompatible pointer type [-Werror]
> 
> To fix this, we can change the remaining prototypes to return an
> integer as well, and always return RX_HANDLER_ANOTHER from rlb_arp_recv.

This has been fixed in Linus's tree for almost 2 days.
