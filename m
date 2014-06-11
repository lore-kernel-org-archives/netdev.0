From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: add skb allocation flags to __pskb_copy
Date: Wed, 11 Jun 2014 00:41:08 -0700 (PDT)
Message-ID: <20140611.004108.1527243476443283864.davem@davemloft.net>
References: <1402179569-19394-1-git-send-email-octavian.purdila@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, christoph.paasch@uclouvain.be
To: octavian.purdila@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43097 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753257AbaFKHlJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 03:41:09 -0400
In-Reply-To: <1402179569-19394-1-git-send-email-octavian.purdila@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <octavian.purdila@intel.com>
Date: Sun,  8 Jun 2014 01:19:29 +0300

> There are several instances where a __pskb_copy is immediately
> followed by an skb_clone. Add a new parameter to __pskb_copy to allow
> the skb to be allocated from the fclone cache and thus speed up
> subsequent skb_clone calls.
> 
> Signed-off-by: Octavian Purdila <octavian.purdila@intel.com>

These SKB_ALLOC_* values are really internal, let's not use them explicitly
outside of skbuff.h and skbuff.c

Change this interface to instead take a boolean, which when true will
cause and fclone allocation.

Thank you.
