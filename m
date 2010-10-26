From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: reset gso header when the copied skb is linearized
Date: Tue, 26 Oct 2010 11:31:57 -0700 (PDT)
Message-ID: <20101026.113157.233700961.davem@davemloft.net>
References: <1288045398-3110-1-git-send-email-fleitner@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: fleitner@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46730
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751796Ab0JZSbe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 14:31:34 -0400
In-Reply-To: <1288045398-3110-1-git-send-email-fleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fleitner@redhat.com>
Date: Mon, 25 Oct 2010 20:23:18 -0200

> The gso header is incorrect when the copied skb is
> linearized. This patch creates another helper function
> to copy the gso header when it is appropriated
> 
> Signed-off-by: Flavio Leitner <fleitner@redhat.com>

I don't understand why the GSO information should be
omitted just because we are creating a linearlized
version of the SKB?

The packet still could have a larger than MSS size,
and thus be composed of multiple actual segments for
the network.
