From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: af_netlink should update its inuse counter
Date: Sun, 23 Nov 2008 15:48:32 -0800 (PST)
Message-ID: <20081123.154832.79729798.davem@davemloft.net>
References: <4927C56A.5080307@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40636
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751075AbYKWXsc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Nov 2008 18:48:32 -0500
In-Reply-To: <4927C56A.5080307@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Sat, 22 Nov 2008 09:40:10 +0100

> In order to have relevant information for NETLINK protocol, in
> /proc/net/protocols, we should use sock_prot_inuse_add() to
> update a (percpu and pernamespace) counter of inuse sockets.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied to net-next-2.6, thanks.
