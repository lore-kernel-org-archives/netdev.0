From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] udp : increments sk_drops in __udp_queue_rcv_skb()
Date: Mon, 02 Feb 2009 13:42:26 -0800 (PST)
Message-ID: <20090202.134226.256784433.davem@davemloft.net>
References: <49871223.2000701@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43070
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760065AbZBBVm3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2009 16:42:29 -0500
In-Reply-To: <49871223.2000701@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 02 Feb 2009 16:32:51 +0100

> udp: increments sk_drops in __udp_queue_rcv_skb()
> 
> Commit 93821778def10ec1e69aa3ac10adee975dad4ff3
> (udp: Fix rcv socket locking) accidentally removed sk_drops increments for
> UDP IPV4 sockets.
> 
> This field can be used to detect incorrect sizing of socket receive buffers.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Yikes, good catch Eric.

Applied and queued up for -stable.
