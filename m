From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] tc35815: Fix an usage of streaming DMA API.
Date: Thu, 15 Mar 2007 11:03:17 -0400
Message-ID: <45F96035.2040403@garzik.org>
References: <20070303.235459.25478204.anemo@mba.ocn.ne.jp> <20070314.010220.65192616.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, ralf@linux-mips.org,
	netdev@vger.kernel.org, sshtylyov@ru.mvista.com,
	akpm@linux-foundation.org
To: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50182 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422863AbXCOPD0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2007 11:03:26 -0400
In-Reply-To: <20070314.010220.65192616.anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Atsushi Nemoto wrote:
> The tc35815 driver lacks a call to pci_dma_sync_single_for_device() on
> receiving.  Recent fix of MIPS dma_sync_single_for_cpu() reveal this
> bug.
> 
> Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
> ---
> This patch can be applied to netdev-2.6 tree or 2.6.21-rc3-mm2.

applied to #upstream


