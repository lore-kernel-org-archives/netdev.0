From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.34] r8169: enable 64-bit DMA by default for PCI
 Express devices (v2)
Date: Fri, 19 Feb 2010 17:10:25 -0800 (PST)
Message-ID: <20100219.171025.09226171.davem@davemloft.net>
References: <4B7CAEC1.6090408@gmail.com>
	<20100219.131718.115496278.davem@davemloft.net>
	<4B7F343E.4040409@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	romieu@fr.zoreil.com
To: hancockrwd@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B7F343E.4040409@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Robert Hancock <hancockrwd@gmail.com>
Date: Fri, 19 Feb 2010 19:00:46 -0600

> Currently use of 64-bit DMA is disabled in r8169 unless the user passes the
> use_dac module option. This is reasonable for conventional PCI devices where
> broken chipsets may not handle dual-address-cycle transfers properly for
> 32-bit slots and so this may not be safe. However, PCI Express should not have
> this problem and not using 64-bit DMA results in DMA transfers needlessly using
> the IOMMU or SWIOTLB. Set the use_dac module parameter to a new default value of
> -1 which results in 64-bit DMA being enabled by default for PCI Express devices
> only.
> 
> Signed-off-by: Robert Hancock <hancockrwd@gmail.com>

Applied, thanks Robert.
