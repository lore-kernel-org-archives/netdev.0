From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlx4: allocate just enough pages instead of always 4
 pages
Date: Wed, 04 Apr 2012 20:34:48 -0400 (EDT)
Message-ID: <20120404.203448.1118889674233934663.davem@davemloft.net>
References: <1333568440-14494-1-git-send-email-cascardo@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roland@kernel.org, ogerlitz@mellanox.com,
	yevgenyp@mellanox.co.il, alexg@mellanox.co.il,
	klebers@linux.vnet.ibm.com
To: cascardo@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51398 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754062Ab2DEAfF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 20:35:05 -0400
In-Reply-To: <1333568440-14494-1-git-send-email-cascardo@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Date: Wed,  4 Apr 2012 16:40:40 -0300

> The driver uses a 2-order allocation, which is too much on architectures
> like ppc64, which has a 64KiB page. This particular allocation is used
> for large packet fragments that may have a size of 512, 1024, 4096 or
> fill the whole allocation. So, a minimum size of 16384 is good enough
> and will be the same size that is used in architectures of 4KiB sized
> pages.
> 
> This will avoid allocation failures that we see when the system is under
> stress, but still has plenty of memory, like the one below.
> 
> This will also allow us to set the interface MTU to higher values like
> 9000, which was not possible on ppc64 without this patch.
 ...
> Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
> Signed-off-by: Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>
> Tested-by: Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>

Applied, thanks a lot.
