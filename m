From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] core: Copy inner_protocol in copy_skb_header()
Date: Wed, 03 Jul 2013 16:52:38 -0700 (PDT)
Message-ID: <20130703.165238.851587445124129294.davem@davemloft.net>
References: <1372835065-32087-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@wand.net.nz
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39414 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754515Ab3GCXwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 19:52:39 -0400
In-Reply-To: <1372835065-32087-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>
Date: Wed,  3 Jul 2013 16:04:25 +0900

> From: Joe Stringer <joe@wand.net.nz>
> 
> inner_protocol was added to struct sk_buff in
> 0d89d2035fe063461a5ddb609b2c12e7fb006e44 ("MPLS: Add limited GSO support"),
> which is scheduled to be included in v3.11.
> 
> That patch did not update __copy_skb_header to copy the inner_protocol.
> 
> Signed-off-by: Joe Stringer <joe@wand.net.nz>
> Signed-off-by: Simon Horman <horms@verge.net.au>

Applied.
