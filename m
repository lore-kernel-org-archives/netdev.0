From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: call ipv6_proxy_select_ident instead of
 ipv6_select_ident in udp6_ufo_fragment
Date: Fri, 20 Mar 2015 13:19:26 -0400 (EDT)
Message-ID: <20150320.131926.197214642484668848.davem@davemloft.net>
References: <20150319101036.GA10040@kria>
	<1426760552-10535-1-git-send-email-sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, matt@mattgrant.net.nz, vyasevic@redhat.com
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35913 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751123AbbCTRTb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 13:19:31 -0400
In-Reply-To: <1426760552-10535-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Thu, 19 Mar 2015 11:22:32 +0100

> Matt Grant reported frequent crashes in ipv6_select_ident when
> udp6_ufo_fragment is called from openvswitch on a skb that doesn't
> have a dst_entry set.
> 
> ipv6_proxy_select_ident generates the frag_id without using the dst
> associated with the skb.  This approach was suggested by Vladislav
> Yasevich.
> 
> Fixes: 0508c07f5e0c ("ipv6: Select fragment id during UFO segmentation if not set.")
> Cc: Vladislav Yasevich <vyasevic@redhat.com>
> Reported-by: Matt Grant <matt@mattgrant.net.nz>
> Tested-by: Matt Grant <matt@mattgrant.net.nz>
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Applied and queued up for -stable, thanks.
