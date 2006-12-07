From: Muli Ben-Yehuda <muli@il.ibm.com>
Subject: Re: network devices don't handle pci_dma_mapping_error()'s
Date: Thu, 7 Dec 2006 15:04:16 +0200
Message-ID: <20061207130416.GD2926@rhun.haifa.ibm.com>
References: <200612011340.kB1DeEhR014690@dut39.unminc.com> <20061206101644.27eeaf14@freekitty> <20061206193328.GB3524@rhun.ibm.com> <200612071148.14996.amitkale@linsyssoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Jeff Garzik <jeff@garzik.org>,
	"Amit S. Kale" <amitkale@netxen.com>, netdev@vger.kernel.org,
	brazilnut@us.ibm.com, netxenproj@linsyssoft.com, rob@netxen.com,
	romieu@fr.zoreil.com, sanjeev@netxen.com, wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:16249 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1032193AbWLGNEU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Dec 2006 08:04:20 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.13.8/8.13.8) with ESMTP id kB7D4ID7140766
	for <netdev@vger.kernel.org>; Thu, 7 Dec 2006 13:04:19 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kB7D4Ix33027190
	for <netdev@vger.kernel.org>; Thu, 7 Dec 2006 14:04:19 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kB7D4HEp023551
	for <netdev@vger.kernel.org>; Thu, 7 Dec 2006 14:04:18 +0100
To: "Amit S. Kale" <amitkale@linsyssoft.com>
Content-Disposition: inline
In-Reply-To: <200612071148.14996.amitkale@linsyssoft.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 07, 2006 at 11:48:14AM +0530, Amit S. Kale wrote:

> On the x86_64 boxes that don't feature iommu functionality (because the 
> motherboard disables it or because Linux can't handle it) Linux bounce buffer 
> framework automatically comes into picture. Could we have the same framework 
> take over when IOMMU space is over? I don't think this is possible with 
> present code, though. We probably can have fallback_dma_ops in addition to 
> dma_ops.

In the general case, no - some platforms (including x86-64 on IBM's
high end servers!) have an isolation capable IOMMU, which means all
DMA mappings need to go through it, so a general mechanism to cope
with DMA mappings running out is still needed.

Cheers,
Muli
