From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] amd-xgbe: Rename MAX_DMA_CHANNELS to avoid powerpc
 conflict
Date: Wed, 11 Jun 2014 00:57:06 -0700 (PDT)
Message-ID: <20140611.005706.1903191769820382324.davem@davemloft.net>
References: <20140609141931.30639.72028.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com, kbuild-all@01.org,
	jet.chen@intel.com
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43174 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754058AbaFKH5H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 03:57:07 -0400
In-Reply-To: <20140609141931.30639.72028.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Mon, 9 Jun 2014 09:19:32 -0500

> MAX_DMA_CHANNELS is defined in asm/scatterlist.h of the powerpc
> architecture.  Rename this #define in xgbe.h to avoid the
> redefined warning issued during compilation.
> 
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>

Applied to net-next, thanks.
