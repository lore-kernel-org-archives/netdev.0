From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2][PPPOL2TP]: Fix SMP issues in skb reorder queue
 handling
Date: Wed, 05 Mar 2008 18:40:14 -0800 (PST)
Message-ID: <20080305.184014.240862635.davem@davemloft.net>
References: <200803052320.m25NKdVP003905@quickie.katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jarkao2@gmail.com
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42747
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759312AbYCFCkO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 21:40:14 -0500
In-Reply-To: <200803052320.m25NKdVP003905@quickie.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Chapman <jchapman@katalix.com>
Date: Wed, 5 Mar 2008 23:20:39 GMT

> When walking a session's packet reorder queue, use
> skb_queue_walk_safe() since the list could be modified inside the
> loop.
> 
> Rearrange the unlinking skbs from the reorder queue such that it
> is done while the queue lock is held in pppol2tp_recv_dequeue() when
> walking the skb list.
> 
> Signed-off-by: James Chapman <jchapman@katalix.com>

Also applied, th anks.
