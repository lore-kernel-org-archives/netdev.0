From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] be2net: use CSR-BAR SEMAPHORE reg for BE2/BE3
Date: Wed, 06 Mar 2013 14:57:37 -0500 (EST)
Message-ID: <20130306.145737.836667338740542833.davem@davemloft.net>
References: <eb9ec39f-6c12-4f1d-ae31-9f1e9ba76848@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58731 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752810Ab3CFT5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 14:57:40 -0500
In-Reply-To: <eb9ec39f-6c12-4f1d-ae31-9f1e9ba76848@CMEXHTCAS1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Wed, 6 Mar 2013 13:53:20 +0530

> The SLIPORT_SEMAPHORE register shadowed in the
> config-space may not reflect the correct POST stage after
> an EEH reset in BE2/3; it may return FW_READY state even though
> FW is not ready. This causes the driver to prematurely
> poll the FW mailbox and fail.
> 
> For BE2/3 use the CSR-BAR/0xac instead.
> 
> Reported-by: Gavin Shan <shangw@linux.vnet.ibm.com>
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

Applied, thanks.
