From: David Miller <davem@davemloft.net>
Subject: Re: [IPv4] ESP: Discard dummy packets introduced in rfc4303
Date: Mon, 10 Dec 2007 16:53:57 -0800 (PST)
Message-ID: <20071210.165357.115406037.davem@davemloft.net>
References: <20071210221703.GG11220@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@damveloft.net, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56749
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751496AbXLKAx6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2007 19:53:58 -0500
In-Reply-To: <20071210221703.GG11220@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Mon, 10 Dec 2007 23:17:03 +0100

> RFC4303 introduces dummy packets with a nexthdr value of 59
> to implement traffic confidentiality. Such packets need to
> be dropped silently and the payload may not be attempted to
> be parsed as it consists of random chunk.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied to net-2.6, since this is more of a bug fix than
anything else.
