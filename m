From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rionet: fix page allocation order of rionet_active
Date: Sun, 01 Apr 2012 23:17:58 -0400 (EDT)
Message-ID: <20120401.231758.636936187534240046.davem@davemloft.net>
References: <1333105306-2601-1-git-send-email-akinobu.mita@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mporter@kernel.crashing.org,
	alexandre.bounine@idt.com
To: akinobu.mita@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47107 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754034Ab2DBDSO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 23:18:14 -0400
In-Reply-To: <1333105306-2601-1-git-send-email-akinobu.mita@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Akinobu Mita <akinobu.mita@gmail.com>
Date: Fri, 30 Mar 2012 20:01:46 +0900

> rionet_active is allocated from the page allocator and the allocation
> order is calculated on the assumption that the page size is 4KB, so it
> wastes memory on more than 4K page systems.
> 
> Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>

Applied, thanks.
