From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] geneve: clear IFF_TX_SKB_SHARING
Date: Thu, 18 Feb 2016 14:56:04 -0500 (EST)
Message-ID: <20160218.145604.1722038452773081388.davem@davemloft.net>
References: <ff77ee3522f56d1f4ab4381fca130978c0d3fca4.1455719425.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@kernel.org
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46299 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423242AbcBRT4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 14:56:05 -0500
In-Reply-To: <ff77ee3522f56d1f4ab4381fca130978c0d3fca4.1455719425.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Wed, 17 Feb 2016 15:31:35 +0100

> ether_setup sets IFF_TX_SKB_SHARING but this is not supported by geneve as
> it modifies the skb on xmit.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Applied.
