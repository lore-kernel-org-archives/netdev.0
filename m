From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2: Fix IRQ failures during kdump.
Date: Sat, 29 May 2010 16:05:27 -0700 (PDT)
Message-ID: <20100529.160527.108793180.davem@davemloft.net>
References: <20100528.235052.241451895.davem@davemloft.net>
	<C27F8246C663564A84BB7AB3439772421B78147573@IRVEXCHCCR01.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grundler@parisc-linux.org, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: mchan@broadcom.com
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <C27F8246C663564A84BB7AB3439772421B78147573@IRVEXCHCCR01.corp.ad.broadcom.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Sat, 29 May 2010 09:22:07 -0700

> I think there may be more issues after thinking about it some more.
> The device is essentially still active at this time.  The PCI
> layer can turn off certain things, but enabling INTX can lead to
> "irq x: nobody cared" if the driver is not ready for it.  The
> device really needs to be reset by the driver to be totally
> reliable.

We still have to find some generic way to do this.

My position still stands, and it is entirely rediculious to
have every single driver have to attend to all of these
esoteric details just to handle interrupts properly.  Drivers
are hard enough to write as-is.
