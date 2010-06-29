From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] tcp: tso_fragment() might avoid GFP_ATOMIC
Date: Mon, 28 Jun 2010 23:38:01 -0700 (PDT)
Message-ID: <20100628.233801.02282025.davem@davemloft.net>
References: <1277377222.2816.296.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37652
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752363Ab0F2Ghs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 02:37:48 -0400
In-Reply-To: <1277377222.2816.296.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 24 Jun 2010 13:00:22 +0200

> We can pass a gfp argument to tso_fragment() and avoid GFP_ATOMIC
> allocations sometimes.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.

Slow down Eric, you're on fire :-)
