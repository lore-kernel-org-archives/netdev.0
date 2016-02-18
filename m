From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] vxlan: clear IFF_TX_SKB_SHARING
Date: Thu, 18 Feb 2016 14:55:58 -0500 (EST)
Message-ID: <20160218.145558.381963904313384337.davem@davemloft.net>
References: <ad978a069caa3c84931b9f0eca7a268f9b459963.1455656611.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46294 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423242AbcBRTz7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 14:55:59 -0500
In-Reply-To: <ad978a069caa3c84931b9f0eca7a268f9b459963.1455656611.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Tue, 16 Feb 2016 22:16:53 +0100

> ether_setup sets IFF_TX_SKB_SHARING but this is not supported by vxlan as it
> modifies the skb on xmit.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Applied.
