From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/3] ixgbe: Fix DMA mapping/unmapping
 issues when HWRSC is enabled on IOMMU enabled kernels
Date: Fri, 26 Feb 2010 02:10:38 -0800 (PST)
Message-ID: <20100226.021038.163265697.davem@davemloft.net>
References: <20100226091318.19796.70225.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	mallikarjuna.chilakala@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50653
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752278Ab0BZKKU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 05:10:20 -0500
In-Reply-To: <20100226091318.19796.70225.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 26 Feb 2010 01:14:37 -0800

> From: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> 
> Work around 82599 HW issue when HWRSC is enabled on IOMMU enabled
> kernels. 82599 HW is updating the header information after setting the
> descriptor to done, resulting DMA mapping/unmapping issues on IOMMU
> enabled systems. To work around the issue delay unmapping of first packet
> that carries the header information until end of packet is reached.
> 
> Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
