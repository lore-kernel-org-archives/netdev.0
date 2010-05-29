From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2: Fix IRQ failures during kdump.
Date: Fri, 28 May 2010 23:50:52 -0700 (PDT)
Message-ID: <20100528.235052.241451895.davem@davemloft.net>
References: <1275103462-8527-1-git-send-email-mchan@broadcom.com>
	<20100529064512.GA21336@lackof.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: grundler@parisc-linux.org
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20100529064512.GA21336@lackof.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grant Grundler <grundler@parisc-linux.org>
Date: Sat, 29 May 2010 00:45:12 -0600

> If that's true, then this can't be handled in the generic PCI layer (as
> suggested by davem) unless the device driver could register multiple interrupt
> handlers even if only one is active at a time.

The generic PCI layer very well can turn off MSI on all devices
when it starts up or a device is plugged in.

That's all he is doing.

Drivers essentially expect that the device comes up in INTX mode
when the driver probes the device.  All his change is doing
is forcing that to be true, and there is no reason the generic
PCI code can't do that.
