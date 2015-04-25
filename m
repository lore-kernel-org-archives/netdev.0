From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: eth: altera: Resolve false errors from MSGDMA to
 TSE
Date: Sat, 25 Apr 2015 14:44:00 -0400 (EDT)
Message-ID: <20150425.144400.1784698109604961465.davem@davemloft.net>
References: <1429860727-1359-1-git-send-email-vbridger@opensource.altera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nios2-dev@lists.rocketboards.org,
	linux-kernel@vger.kernel.org, vbridger@altera.com,
	cnphoon@altera.com, ennoerlangen@gmail.com
To: vbridger@opensource.altera.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429860727-1359-1-git-send-email-vbridger@opensource.altera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vince Bridgers <vbridger@opensource.altera.com>
Date: Fri, 24 Apr 2015 02:32:07 -0500

> From: Chee Nouk Phoon <cnphoon@altera.com>
> 
> This patch resolves false errors from MSGDMA in TX mSGDMA MM to ST
> mode, and is a continuation of the patch recently submitted by Andrea
> Oetken. The MSGDMA had a logic bug that masked detection of this issue
> prior to Quartus 14.1/Build 164. When the MSGDMA logic bug was addressed
> in Quartus 14.1/Build 164, the driver problem was exposed.
> 
> The problem is corrected by making sure MSGDMA_DESC_CTL_TR_ERR_IRQ is not
> set for any of the transmit DMA descriptors, and only used for receive
> descriptors.
> 
> Fixes: 71cd26e altera tse: Error-Bit on tx-avalon-stream always set.
> 
> Signed-off-by: Chee Nouk Phoon <cnphoon@altera.com>
> Signed-off-by: Vince Bridgers <vbridger@opensource.altera.com>a
> Cc: Andreas Oetken <ennoerlangen@gmail.com>

Applied.
