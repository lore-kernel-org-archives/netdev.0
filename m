From: David Miller <davem@davemloft.net>
Subject: Re: [net] ixgbe: fix panic while dumping packets on Tx hang with
 IOMMU
Date: Thu, 26 Jul 2012 14:30:35 -0700 (PDT)
Message-ID: <20120726.143035.113701718595617991.davem@davemloft.net>
References: <1343301684-10158-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: emil.s.tantilov@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56133 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753311Ab2GZVag (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 17:30:36 -0400
In-Reply-To: <1343301684-10158-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 26 Jul 2012 04:21:24 -0700

> From: Emil Tantilov <emil.s.tantilov@intel.com>
> 
> This patch resolves a "BUG: unable to handle kernel paging request at ..."
> oops while dumping packet data. The issue occurs with IOMMU enabled due to
> the address provided by phys_to_virt().
> 
> This patch makes use of skb->data on Tx and the virtual address of the pages
> allocated for Rx.
> 
> Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
