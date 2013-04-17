From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/5] tipc: add TIPC over Infiniband support
Date: Wed, 17 Apr 2013 14:19:06 -0400 (EDT)
Message-ID: <20130417.141906.1942482291109662532.davem@davemloft.net>
References: <1366215509-18500-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, allan.stephens@windriver.com,
	netdev@vger.kernel.org, roland@kernel.org, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, linux-rdma@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36199 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966081Ab3DQSTI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 14:19:08 -0400
In-Reply-To: <1366215509-18500-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 17 Apr 2013 18:18:24 +0200

> The following patchset adds support for running TIPC over InfiniBand.
> The patchset consists of three parts (+ a minor fix for the ethernet media
> type):
> 
> - Preparation: removal of an the unused str2addr callback and move of the
>   bcast_addr from struct tipc_media to struct tipc_bearer. This is necessary
>   because InfiniBand doesn't have a fixed broadcast address like ethernet,
>   so it needs to be initialized with the device's broadcast address when
>   the bearer is enabled
> 
> - Introduction of a TIPC InfiniBand media type. A new media type is needed
>   to deal with the different address sizes
> 
> - Support for ETH_P_TIPC in IPoIB
> 
> Since the last posting I've addressed all feedback I received and rebased
> to the current net-next tree.
> 
> I consider these patches ready for merging. Since they mainly affect TIPC
> code, I'd propose to have them either go through the TIPC tree or through
> Dave directly (not sure how TIPC patches are managed).

All applied to net-next, thanks!
