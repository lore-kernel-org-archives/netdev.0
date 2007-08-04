From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH] ixgbe: New driver for Pci-Express 10GbE 82598 support
Date: Sat, 4 Aug 2007 15:04:01 -0400
Message-ID: <20070804150401.afb6b709.billfink@mindspring.com>
References: <20070804040502.D9133F2C0F@doppio.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	ayyappan.veeraiyan@intel.com, akpm@linux-foundation.org,
	arjan@linux.intel.com, hch@infradead.org,
	shemminger@linux-foundation.org, nhorman@tuxdriver.com,
	inaky@linux.intel.com, mb@bu3sch.de, john.ronciak@intel.com
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-masked.atl.sa.earthlink.net ([209.86.89.68]:60313 "EHLO
	elasmtp-masked.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1765406AbXHDTEO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Aug 2007 15:04:14 -0400
In-Reply-To: <20070804040502.D9133F2C0F@doppio.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 3 Aug 2007, Auke Kok wrote:

> This patch adds support for the Intel 82598 PCI-Express 10GbE
> chipset. Devices will be available on the market soon.
> 
> This version of the driver is largely the same as the last release:
> 
> * Driver uses a single RX and single TX queue, each using 1 MSI-X
>   irq vector.
> * Driver runs in NAPI mode only
> * Driver is largely multiqueue-ready (TM)

...

> diff --git a/Documentation/networking/ixgbe.txt b/Documentation/networking/ixgbe.txt
> new file mode 100644
> index 0000000..823d69c
> --- /dev/null
> +++ b/Documentation/networking/ixgbe.txt
> @@ -0,0 +1,72 @@
> +Linux* Base Driver for the 10 Gigabit Family of Adapters
> +================================================================
> +
> +July 09, 2007
> +
> +
> +Contents
> +========
> +
> +- In This Release
> +- Identifying Your Adapter
> +- Command Line Parameters

There is no section "Command Line Parameters" in the document.

						-Bill



> +- Support
> +
> +In This Release
> +===============
> +
> +This file describes the Linux* Base Driver for the 10 Gigabit PCI Express
> +Family of Adapters.  This driver supports the 2.6.x kernel. This driver
> +includes support for Itanium(R)2-based systems.
> +
> +The following features are now available in supported kernels:
> + - Native VLANs
> + - Channel Bonding (teaming)
> + - SNMP
> +
> +Channel Bonding documentation can be found in the Linux kernel source:
> +/Documentation/networking/bonding.txt
> +
> +Instructions on updating ethtool can be found in the section "Additional
> +Configurations" later in this document.
> +
> +
> +Identifying Your Adapter
> +========================
> +
> +The following Intel network adapters are compatible with the drivers in this
> +release:
> +
> +Controller  Adapter Name                 Physical Layer
> +----------  ------------                 --------------
> +82598       Intel(R) 10GbE-LR/LRM/SR
> +            Server Adapters              10G Base -SR (850 nm optical fiber)
> +                                         10G Base -LRM (850 nm optical fiber)
> +                                         10G Base -LR (1310 nm optical fiber)
> +
> +For more information on how to identify your adapter, go to the Adapter &
> +Driver ID Guide at:
> +
> +    http://support.intel.com/support/network/sb/CS-012904.htm
> +
> +For the latest Intel network drivers for Linux, refer to the following
> +website.  In the search field, enter your adapter name or type, or use the
> +networking link on the left to search for your adapter:
> +
> +    http://downloadfinder.intel.com/scripts-df/support_intel.asp
> +
> +
> +Support
> +=======
> +
> +For general information, go to the Intel support website at:
> +
> +    http://support.intel.com
> +
> +or the Intel Wired Networking project hosted by Sourceforge at:
> +
> +    http://sourceforge.net/projects/e1000
> +
> +If an issue is identified with the released source code on the supported
> +kernel with a supported adapter, email the specific information related
> +to the issue to e1000-devel@lists.sf.net
