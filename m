From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: __mkroute_output() speedup
Date: Thu, 30 Sep 2010 21:16:42 -0700 (PDT)
Message-ID: <20100930.211642.135520056.davem@davemloft.net>
References: <1285797230.5211.173.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48250
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750821Ab0JAEQW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Oct 2010 00:16:22 -0400
In-Reply-To: <1285797230.5211.173.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 29 Sep 2010 23:53:50 +0200

> While doing stress tests with a disabled IP route cache, I found
> __mkroute_output() was touching three times in_device atomic refcount.
> 
> Use RCU to touch it once to reduce cache line ping pongs.
 ...
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
