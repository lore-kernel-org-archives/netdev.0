From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH] atl1c: Fix misuse of netdev_alloc_skb in refilling
 rx ring
Date: Sun, 28 Jul 2013 17:21:38 -0700 (PDT)
Message-ID: <20130728.172138.870691960277941452.davem@davemloft.net>
References: <1375052482.3669.54.camel@edumazet-glaptop>
	<1375053654.3669.58.camel@edumazet-glaptop>
	<1375056438.2546.55.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, nhorman@tuxdriver.com,
	luis.henriques@canonical.com, netdev@vger.kernel.org,
	jcliburn@gmail.com, stable@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1375056438.2546.55.camel@deadeye.wl.decadent.org.uk>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 29 Jul 2013 01:07:18 +0100

> Just like many older PCI/PCIe devices.  So what?  pci_map_single() takes
> care of that, just so long as the driver sets the DMA mask correctly.
> In fact, PCI devices have a 32-bit DMA mask by default.

Right, the DMA API should be taking care of this.
