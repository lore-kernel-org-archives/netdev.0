From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: Re: [PATCH -next 1/2] net: bfin_mac: Fix error handling in probe
 function
Date: Mon, 11 Jan 2016 14:13:51 +0530
Message-ID: <20160111084350.GC8070@sudip-pc>
References: <1452357427-30578-1-git-send-email-linux@roeck-us.net>
 <20160109165802.GD28813@lunn.ch>
 <56914D21.9050804@roeck-us.net>
 <20160109205240.GA6877@lunn.ch>
 <569275C0.1040606@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>,
	"David S. Miller" <davem@davemloft.net>,
	adi-buildroot-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <569275C0.1040606@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 10, 2016 at 07:16:16AM -0800, Guenter Roeck wrote:
> On 01/09/2016 12:52 PM, Andrew Lunn wrote:
> >On Sat, Jan 09, 2016 at 10:10:41AM -0800, Guenter Roeck wrote:
> >>Hi Andrew,
> >>
> >>On 01/09/2016 08:58 AM, Andrew Lunn wrote:
> >>>Hi Guenter
> >>>
> >>>Same fix was submitted yesterday by Sudip Mukherjee.
> >>>
> >>
> >>I missed that one, sorry.
> >>
> >>How about drivers/net/ethernet/toshiba/tc35815.c ? It now has an unused
> >>variable due to e7f4dc3536a4, and it fails to build because of 7f854420fbfe.
> >>
> >>Which leads to the question which of the other build failures due to
> >>7f854420fbfe have been addressed already. In addition to the toshiba driver,
> >>I see build failures in drivers/net/ethernet/ti/cpmac.c and possibly
> >>drivers/staging/octeon/ethernet-rgmii.c (the error message is different,
> >>so it may be something else).
> >>
> >>I don't see patches for those, but I guess I must be blind, so I figure I
> >>better ask before I send out mine.
> >
> >That i have seen so far:
> >
> >Wantiq_etp.c: Me
> >octeon/ethernet-rgmii.c: Me
> >adi/bfin_mac.c: Sudip Mukerjee
> 
> I re-posted this one anyway, using phy_find_first.
> 
> >nxp/lpc_eth.c: Fabio Estevam
> >
> >Plus there is an interesting one for micrel.c which is going to have
> >to wait a while.
> >
> How about those ?
> 
> drivers/net/ethernet/freescale/ucc_geth.c: In function 'uec_configure_serdes':
> drivers/net/ethernet/freescale/ucc_geth.c:1719:20: error: 'struct phy_device' has no member named 'dev'
> 
> drivers/net/ethernet/freescale/fs_enet/mac-fec.c: In function 'stop':
> drivers/net/ethernet/freescale/fs_enet/mac-fec.c:366:36: error: 'struct phy_device' has no member named 'bus'

My builds didn't show them not even the other ones mentioned above. :(
Which config you used for these?

regards
sudip
