From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net] net: WARN if skb_checksum_help() is called on
 skb requiring segmentation
Date: Tue, 17 Jan 2012 15:49:12 -0500 (EST)
Message-ID: <20120117.154912.944088870403029424.davem@davemloft.net>
References: <1326823076.2478.19.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.hengli.com.au
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57827 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752819Ab2AQUtS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 15:49:18 -0500
In-Reply-To: <1326823076.2478.19.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 17 Jan 2012 17:57:56 +0000

> skb_checksum_help() has never done anything useful with skbs that
> require segmentation.  Setting skb->ip_summed = CHECKSUM_NONE makes
> them invalid and provokes a later WARNing in skb_gso_segment().
> 
> Passing such an skb to skb_checksum_help() indicates a bug, so we
> should warn about it immediately.  Move the warning from
> skb_gso_segment() into a shared function, and add gso_type and
> gso_size to it.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
