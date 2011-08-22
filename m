From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next-2.6] net: vlan: goto another_round instead of
 calling __netif_receive_skb
Date: Mon, 22 Aug 2011 12:43:31 -0700 (PDT)
Message-ID: <20110822.124331.586969824092742628.davem@davemloft.net>
References: <1314040135-3414-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, mirqus@gmail.com, jesse@nicira.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58624 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753108Ab1HVToH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2011 15:44:07 -0400
In-Reply-To: <1314040135-3414-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Mon, 22 Aug 2011 21:08:55 +0200

> Now, when vlan tag on untagged in non-accelerated path is stripped from
> skb, headers are reset right away. Benefit from that and avoid calling
> __netif_receive_skb recursivelly and just use another_round.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied, thanks.
