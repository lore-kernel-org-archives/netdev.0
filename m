From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] ixgbe: New driver for Pci-Express 10GbE 82598 support
Date: Wed, 08 Aug 2007 08:56:28 -0700
Message-ID: <46B9E7AC.10509@intel.com>
References: <20070804040502.D9133F2C0F@doppio.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, ayyappan.veeraiyan@intel.com,
	akpm@linux-foundation.org, arjan@linux.intel.com,
	hch@infradead.org, shemminger@linux-foundation.org,
	nhorman@tuxdriver.com, inaky@linux.intel.com, mb@bu3sch.de,
	john.ronciak@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:1600 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762114AbXHHP4d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Aug 2007 11:56:33 -0400
In-Reply-To: <20070804040502.D9133F2C0F@doppio.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> This patch adds support for the Intel 82598 PCI-Express 10GbE
> chipset. Devices will be available on the market soon.
> 
> This version of the driver is largely the same as the last release:
> 
> * Driver uses a single RX and single TX queue, each using 1 MSI-X
>   irq vector.
> * Driver runs in NAPI mode only
> * Driver is largely multiqueue-ready (TM)


For those interested in the specs of the product and all the features that it 
supports, I just noticed that the product brief was posted on our website with 
all the features and facts on the 82598-based products. Please take a look:


Overview:
   http://www.intel.com/design/network/products/lan/controllers/82598.htm

Product brief:
   http://download.intel.com/design/network/prodbrf/317796.pdf


Cheers,

Auke
