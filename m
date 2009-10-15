From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: sk_drops consolidation
Date: Wed, 14 Oct 2009 20:40:21 -0700 (PDT)
Message-ID: <20091014.204021.97690983.davem@davemloft.net>
References: <4AD68D4C.2080108@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45577
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932081AbZJODkZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2009 23:40:25 -0400
In-Reply-To: <4AD68D4C.2080108@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 15 Oct 2009 04:47:40 +0200

> sock_queue_rcv_skb() can update sk_drops itself, removing need for
> callers to take care of it. This is more consistent since
> sock_queue_rcv_skb() also reads sk_drops when queueing a skb.
> 
> This adds sk_drops managment to many protocols that not cared yet.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Looks great, applied.
