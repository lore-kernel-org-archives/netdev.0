From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: af_packet should update its inuse counter
Date: Wed, 19 Nov 2008 14:25:43 -0800 (PST)
Message-ID: <20081119.142543.192726776.davem@davemloft.net>
References: <49214C1F.2060000@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53681
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751210AbYKSWZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 17:25:43 -0500
In-Reply-To: <49214C1F.2060000@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 17 Nov 2008 11:49:03 +0100

> This patch is a preparation to namespace conversion of /proc/net/protocols
> 
> In order to have relevant information for PACKET protocols, we should use
> sock_prot_inuse_add() to update a (percpu and pernamespace) counter of
> inuse sockets.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied to net-next-2.6, thanks.
