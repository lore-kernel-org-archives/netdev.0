From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 0/4] stmmac: pci: Fix crash on Intel Galileo Gen2
Date: Mon, 08 May 2017 15:15:57 -0400 (EDT)
Message-ID: <20170508.151557.1146408229474904058.davem@davemloft.net>
References: <20170508141422.39612-1-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Joao.Pinto@synopsys.com, jan.kiszka@siemens.com,
        netdev@vger.kernel.org, peppe.cavallaro@st.com
To: andriy.shevchenko@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35864 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754140AbdEHTP7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 15:15:59 -0400
In-Reply-To: <20170508141422.39612-1-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Mon,  8 May 2017 17:14:18 +0300

> Due to misconfiguration of PCI driver for Intel Quark the user will get
> a kernel crash:
> 
> # udhcpc -i eth0
> udhcpc: started, v1.26.2
> stmmaceth 0000:00:14.6 eth0: device MAC address 98:4f:ee:05:ac:47
> Generic PHY stmmac-a6:01: attached PHY driver [Generic PHY] (mii_bus:phy_addr=stmmac-a6:01, irq=-1)
> stmmaceth 0000:00:14.6 eth0: IEEE 1588-2008 Advanced Timestamp supported
> stmmaceth 0000:00:14.6 eth0: registered PTP clock
> IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
> 
> udhcpc: sending discover
> 
> stmmaceth 0000:00:14.6 eth0: Link is Up - 100Mbps/Full - flow control off
> IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
> BUG: unable to handle kernel NULL pointer dereference at (null)
> IP: stmmac_xmit+0xf1/0x1080
> 
> Fix this by adding necessary settings.
> 
> P.S. I split fix to three patches according to what each of them adds.

Looks good, series applied, thanks.
