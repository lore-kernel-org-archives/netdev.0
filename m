From: David Miller <davem@davemloft.net>
Subject: Re: net: af_packet: skb_orphan should be avoided in TX path.
Date: Wed, 08 Sep 2010 10:39:12 -0700 (PDT)
Message-ID: <20100908.103912.183063631.davem@davemloft.net>
References: <1283708635.3402.100.camel@edumazet-laptop>
	<20100906103505.GA15254@redhat.com>
	<1283787867.2654.600.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, xiaosuo@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49487
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751098Ab0IHRiy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 13:38:54 -0400
In-Reply-To: <1283787867.2654.600.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 06 Sep 2010 17:44:27 +0200

> skb_orphan() is not about protecting data, but doing per socket memory
> accounting.

Right, therefore I would suggest we use a different callback mechanism
for af_packet to fix this problem.
