From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/2] net: Remote checksum offload for VXLAN
Date: Wed, 14 Jan 2015 15:21:29 -0500 (EST)
Message-ID: <20150114.152129.1086585159807498251.davem@davemloft.net>
References: <1421110838-5146-1-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45002 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751276AbbANUVc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 15:21:32 -0500
In-Reply-To: <1421110838-5146-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon, 12 Jan 2015 17:00:36 -0800

> This patch set adds support for remote checksum offload in VXLAN.
> 
> The remote checksum offload is generalized by creating a common
> function (remcsum_adjust) that does the work of modifying the
> checksum in remote checksum offload. This function can be called
> from normal or GRO path. GUE was modified to use this function.
> 
> To support RCO is VXLAN we use the 9th bit in the reserved
> flags to indicated remote checksum offload. The start and offset
> values are encoded n a compressed form in the low order (reserved)
> byte of the vni field.
> 
> Remote checksum offload is described in
> https://tools.ietf.org/html/draft-herbert-remotecsumoffload-01

Tom's arguments for why he separates RX and TX paths seem completely
reasonable, and match my own understanding of the various tunneling
technologies we support.

Therefore, series applied, thanks!
