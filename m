From: David Miller <davem@davemloft.net>
Subject: Re: [RFC !!BONUS!! PATCH 6/5] ipv4: Delete routing cache.
Date: Thu, 03 Mar 2011 13:44:03 -0800 (PST)
Message-ID: <20110303.134403.27802454.davem@davemloft.net>
References: <20110209.223939.246547003.davem@davemloft.net>
	<20110215.185534.71133854.davem@davemloft.net>
	<1297842977.3201.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41561
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758618Ab1CCVn0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 16:43:26 -0500
In-Reply-To: <1297842977.3201.7.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 16 Feb 2011 08:56:17 +0100

> I suspect we can zap DST_NOCACHE later ?

So, coming back to this, we really can't since IPV6 and DecNET
still need the non-DST_NOCACHE case.
