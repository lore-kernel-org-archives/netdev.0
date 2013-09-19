From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 2/2] ip: generate unique IP identificator if
 local fragmentation is allowed
Date: Thu, 19 Sep 2013 14:11:36 -0400 (EDT)
Message-ID: <20130919.141136.38349564506650340.davem@davemloft.net>
References: <1379543393-7446-1-git-send-email-aatteka@nicira.com>
	<1379543393-7446-2-git-send-email-aatteka@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: aatteka@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53351 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752519Ab3ISSLi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Sep 2013 14:11:38 -0400
In-Reply-To: <1379543393-7446-2-git-send-email-aatteka@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ansis Atteka <aatteka@nicira.com>
Date: Wed, 18 Sep 2013 15:29:53 -0700

> If local fragmentation is allowed, then ip_select_ident() and
> ip_select_ident_more() need to generate unique IDs to ensure
> correct defragmentation on the peer.
> 
> For example, if IPsec (tunnel mode) has to encrypt large skbs
> that have local_df bit set, then all IP fragments that belonged
> to different ESP datagrams would have used the same identificator.
> If one of these IP fragments would get lost or reordered, then
> peer could possibly stitch together wrong IP fragments that did
> not belong to the same datagram. This would lead to a packet loss
> or data corruption.
> 
> Signed-off-by: Ansis Atteka <aatteka@nicira.com>

Applied.
