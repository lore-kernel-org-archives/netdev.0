From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH RFC v5] net: add PCINet driver
Date: Thu, 15 Jan 2009 18:53:51 +0100
Message-ID: <200901151853.52202.arnd@arndb.de>
References: <20090107195052.GA24981@ovro.caltech.edu> <200901151358.34250.arnd@arndb.de> <20090115165359.GA2230@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: Ira Snyder <iws@ovro.caltech.edu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763353AbZAORyU@vger.kernel.org>
In-Reply-To: <20090115165359.GA2230@ovro.caltech.edu>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 15 January 2009, Ira Snyder wrote:
> 
> These are PCI boards, not PCIe. The host computers are all Pentium3-M
> systems. I tried enabling MSI on the Freescale boards in the driver, by
> calling pci_enable_msi() during probe(), and it failed. 

That doesn't really mean anything, just that the PCI endpoint doesn't
announce its capability to do MSI in the config space, or that it
does not have an interrupt line. Since you basically implement the
device on the FSL board, you should also be able to define the interrupt
capabilities by writing to the config space.

Do you know what kind of chipset the host uses? It should be fairly
simple to find out whether or not it can do MSI.

	Arnd <><
