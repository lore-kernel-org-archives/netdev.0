From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [net-next PATCH 0/3] Adding phy register fixup in DT
Date: Tue, 23 Apr 2013 10:02:57 +0200
Message-ID: <20130423080257.GQ32299@pengutronix.de>
References: <1366654838-26479-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	linux-omap@vger.kernel.org, davem@davemloft.net
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:44259 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755617Ab3DWIDF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 04:03:05 -0400
Content-Disposition: inline
In-Reply-To: <1366654838-26479-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 22, 2013 at 11:50:35PM +0530, Mugunthan V N wrote:
> In earlier days phy fixup was added to phy frame work in board files.
> As there won't be any board files here after the same has to be done in DT
> This patch series adds the following features
> * support for adding phy resigter fixup via DT
> * adds phy id for EVMsk n DTS file
> * adds phy fixup for AM335x EVM and EVMsk
> 
> Mugunthan V N (3):
>   drivers: of: add phy fixup support in DT
>   ARM: dts: AM33XX: Add CPSW phy_id device tree data to am335x-evmsk
>   ARM: dts: AM33XX: add phy fixup for evm and evmsk boards

I generally do not offend to phy fixups from the devicetree. I see
though that becomes more and more common that we have to configure
the tx delays in phys.

The current way seems to be to hardcode register values for each board
which seems not very flexible and forces us to read phy datasheets
each time for a new board.

Wouldn't it make more sense to configure the actual delays (in ns) and
let the phy drivers figure out how to turn this into register values?

Not that I volunteer to write such things... :-/

Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
