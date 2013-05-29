From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/7] Fix fallout from conversion of skb
 headers to 16bit offsets
Date: Tue, 28 May 2013 23:49:24 -0700 (PDT)
Message-ID: <20130528.234924.671517788123866916.davem@davemloft.net>
References: <1369809269-13130-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54135 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932790Ab3E2GtZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 02:49:25 -0400
In-Reply-To: <1369809269-13130-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>
Date: Wed, 29 May 2013 15:34:22 +0900

> Many apologies for not having the foresight to look for these problems earlier.
> 
> These problems relate to comparisons between integer offsets and pointers
> that occur when NET_SKBUFF_DATA_USES_OFFSET is not set
> 
> These are regressions caused by "net: Use 16bits for *_headers fields of
> struct skbuff".

Series applied, thanks Simon.
