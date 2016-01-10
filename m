From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH -next 1/2] net: bfin_mac: Fix error handling in probe
 function
Date: Sun, 10 Jan 2016 16:49:45 +0100
Message-ID: <20160110154945.GD22229@lunn.ch>
References: <1452357427-30578-1-git-send-email-linux@roeck-us.net>
 <20160109165802.GD28813@lunn.ch>
 <56914D21.9050804@roeck-us.net>
 <20160109205240.GA6877@lunn.ch>
 <569275C0.1040606@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	adi-buildroot-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <569275C0.1040606@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> How about those ?
> 
> drivers/net/ethernet/freescale/ucc_geth.c: In function 'uec_configure_serdes':
> drivers/net/ethernet/freescale/ucc_geth.c:1719:20: error: 'struct phy_device' has no member named 'dev'
> 
> drivers/net/ethernet/freescale/fs_enet/mac-fec.c: In function 'stop':
> drivers/net/ethernet/freescale/fs_enet/mac-fec.c:366:36: error: 'struct phy_device' has no member named 'bus'

Not seen fixes for those, nor error reports either.

I think the next time i do something like this, i'm going to ask you
to run some built tests for me! You seem to have better coverage than
0-day.

     Andrew
