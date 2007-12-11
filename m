From: David Miller <davem@davemloft.net>
Subject: Re: [IPv6] ESP: Discard dummy packets introduced in rfc4303
Date: Mon, 10 Dec 2007 16:54:09 -0800 (PST)
Message-ID: <20071210.165409.95011042.davem@davemloft.net>
References: <20071210221807.GH11220@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59113
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751313AbXLKAyK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2007 19:54:10 -0500
In-Reply-To: <20071210221807.GH11220@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Mon, 10 Dec 2007 23:18:07 +0100

> RFC4303 introduces dummy packets with a nexthdr value of 59
> to implement traffic confidentiality. Such packets need to
> be dropped silently and the payload may not be attempted to
> be parsed as it consists of random chunk.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Also applied to net-2.6, thanks Thomas.
