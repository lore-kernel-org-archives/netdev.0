From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] enic: support skb->xmit_more
Date: Wed, 19 Nov 2014 17:02:59 -0500 (EST)
Message-ID: <20141119.170259.796632085538407303.davem@davemloft.net>
References: <1416382172-28775-1-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ssujith@cisco.com, benve@cisco.com,
	eric.dumazet@gmail.com
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39272 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932735AbaKSWDD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 17:03:03 -0500
In-Reply-To: <1416382172-28775-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>
Date: Wed, 19 Nov 2014 12:59:32 +0530

> Check and update posted_index only when skb->xmit_more is 0 or tx queue is full.
> 
> v2:
> use txq_map instead of skb_get_queue_mapping(skb)
> 
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>

Applied, thanks.
