From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] amd-xgbe: Fix sparse endian warnings
Date: Wed, 12 Nov 2014 15:10:42 -0500 (EST)
Message-ID: <20141112.151042.866698841142757300.davem@davemloft.net>
References: <20141112163749.2808.95593.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dan.carpenter@oracle.com
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46142 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753248AbaKLUKq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 15:10:46 -0500
In-Reply-To: <20141112163749.2808.95593.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Wed, 12 Nov 2014 10:37:49 -0600

> Change the types of the descriptor entries in the xgbe_ring_desc struct
> from u32 to __le32 to fix endian warnings issued by sparse.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thank you.
