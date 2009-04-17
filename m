From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.30] Network Drop Monitor: Make use of consume_skb()
 in af_can.c
Date: Fri, 17 Apr 2009 01:38:53 -0700 (PDT)
Message-ID: <20090417.013853.04495551.davem@davemloft.net>
References: <49E78DE5.10104@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org
To: oliver@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35190
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754557AbZDQIjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 04:39:01 -0400
In-Reply-To: <49E78DE5.10104@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <oliver@hartkopp.net>
Date: Thu, 16 Apr 2009 21:58:29 +0200

> Since commit ead2ceb0ec9f85cff19c43b5cdb2f8a054484431 so called end-of-line
> points for skb's should use consume_skb() to free the socket buffer.
> 
> In opposite to consume_skb() the function kfree_skb() is intended to be used
> for unexpected skb drops e.g. in error conditions that now can trigger the
> network drop monitor if enabled.
> 
> This patch moves the skb end-of-line point in af_can.c to use consume_skb().
> 
> Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>

Applied, thanks.
