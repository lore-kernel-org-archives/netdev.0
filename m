From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sctp should update its inuse counter
Date: Mon, 17 Nov 2008 02:41:10 -0800 (PST)
Message-ID: <20081117.024110.29792305.davem@davemloft.net>
References: <492149F6.5060805@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53629
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752835AbYKQKlK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 05:41:10 -0500
In-Reply-To: <492149F6.5060805@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 17 Nov 2008 11:39:50 +0100

> This patch is a preparation to namespace conversion of /proc/net/protocols
> 
> In order to have relevant information for SCTP protocols, we should use
> sock_prot_inuse_add() to update a (percpu and pernamespace) counter of
> inuse sockets.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks Eric.
