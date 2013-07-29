From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net PATCH] atl1c: Fix misuse of netdev_alloc_skb in refilling
 rx ring
Date: Sun, 28 Jul 2013 17:26:34 -0700
Message-ID: <1375057594.3669.64.camel@edumazet-glaptop>
References: <87k3kbdcmy.fsf@canonical.com>
	 <1374960610.3607.13.camel@deadeye.wl.decadent.org.uk>
	 <1374969583.3669.23.camel@edumazet-glaptop>
	 <20130727.200205.67471633133830510.davem@davemloft.net>
	 <20130728104446.GB9876@neilslaptop.think-freely.org>
	 <1375028154.3669.30.camel@edumazet-glaptop>
	 <20130728185318.GA10795@neilslaptop.think-freely.org>
	 <1375042972.2546.17.camel@deadeye.wl.decadent.org.uk>
	 <1375052482.3669.54.camel@edumazet-glaptop>
	 <1375053654.3669.58.camel@edumazet-glaptop>
	 <1375056438.2546.55.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>,
	luis.henriques@canonical.com, netdev@vger.kernel.org,
	jcliburn@gmail.com, stable@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1375056438.2546.55.camel@deadeye.wl.decadent.org.uk>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-07-29 at 01:07 +0100, Ben Hutchings wrote:

> Just like many older PCI/PCIe devices.  So what?  pci_map_single() takes
> care of that, just so long as the driver sets the DMA mask correctly.
> In fact, PCI devices have a 32-bit DMA mask by default.

I don't know, maybe the remapping doesn't work if area splits several
pages ?

I mean, why bouncing memory if we can allocate in the right zone in the
first place ?
