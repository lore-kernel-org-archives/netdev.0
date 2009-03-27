From: "Divy Le Ray" <divy@chelsio.com>
Subject: [PATCH 0/5 2.6.30] cxgb3: driver updates
Date: Thu, 26 Mar 2009 19:39:04 -0700
Message-ID: <op.urfizesdduofyu@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; delsp=yes; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Steve Wise" <swise@opengridcomputing.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:31268 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753248AbZC0CjK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 22:39:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Dave,

I'm submitting a series of patches, targeted for 2.6.30 if
the merge window is not closed.

Here is a brief description of the patches:
- start the SGE reclaim timers only when the sge is fully setup
- update SGE setup to avoid potential H/W issues
- use resource_size_t for the declaration of mmio related variables
- differentiate the adapter ports from the H/W Tx channels
- Reduce DMA mappings to entire pages on Rx to reduce iommu activity

Cheers,
Divy
