From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlx4_en: map entire pages to increase throughput
Date: Mon, 16 Jul 2012 22:29:03 -0700 (PDT)
Message-ID: <20120716.222903.367603216293954363.davem@davemloft.net>
References: <1342458113-10384-1-git-send-email-cascardo@linux.vnet.ibm.com>
	<50044F1D.6000703@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cascardo@linux.vnet.ibm.com, netdev@vger.kernel.org,
	yevgenyp@mellanox.co.il, ogerlitz@mellanox.com, amirv@mellanox.com,
	brking@linux.vnet.ibm.com, leitao@linux.vnet.ibm.com,
	klebers@linux.vnet.ibm.com
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46151 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751675Ab2GQF3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 01:29:04 -0400
In-Reply-To: <50044F1D.6000703@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>
Date: Mon, 16 Jul 2012 10:27:57 -0700

> That seems rather extraordinarily low - Power7 is supposed to be a
> rather high performance CPU.  The last time I noticed O(3Gbit/s) on
> 10G for bulk transfer was before the advent of LRO/GRO - that was in
> the x86 space though.  Is mapping really that expensive with Power7?

Unfortunately, IOMMU mappings are incredibly expensive.  I see effects
like this on Sparc too.
