From: Jan Kiszka <jan.kiszka@siemens.com>
Subject: Re: [PATCH v1 0/4] stmmac: pci: Fix crash on Intel Galileo Gen2
Date: Mon, 8 May 2017 19:34:14 +0200
Message-ID: <ebf3cc78-c139-9b0e-1a16-d0ef095a80da@siemens.com>
References: <20170508141422.39612-1-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        netdev <netdev@vger.kernel.org>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from david.siemens.de ([192.35.17.14]:54556 "EHLO david.siemens.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752179AbdEHRe2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 8 May 2017 13:34:28 -0400
In-Reply-To: <20170508141422.39612-1-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-05-08 16:14, Andy Shevchenko wrote:
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
> 
> Andy Shevchenko (4):
>   stmmac: pci: set default number of rx and tx queues
>   stmmac: pci: TX and RX queue priority configuration
>   stmmac: pci: RX queue routing configuration
>   stmmac: pci: split out common_default_data() helper
> 
>  drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 41 +++++++++++-------------
>  1 file changed, 18 insertions(+), 23 deletions(-)
> 

Tested-by: Jan Kiszka <jan.kiszka@siemens.com>

All fine again, thanks!

Jan

-- 
Siemens AG, Corporate Technology, CT RDA ITP SES-DE
Corporate Competence Center Embedded Linux
