From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 0/2] skb recycling
Date: Wed, 01 Oct 2008 02:34:51 -0700 (PDT)
Message-ID: <20081001.023451.241472852.davem@davemloft.net>
References: <20080928204616.GA19070@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ram.Natarajan@Emulex.Com,
	dada1@cosmosbay.com, akarkare@marvell.com, nico@cam.org
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49163
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750751AbYJAJfE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 05:35:04 -0400
In-Reply-To: <20080928204616.GA19070@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Sun, 28 Sep 2008 22:46:16 +0200

> This implements skb recycling, which is basically just reusing skbuffs
> that have finished transmitting as receive buffers, avoiding skbuff
> freeing/reallocation overhead.  This is done by having the networking
> provide skb_recycle_check(), which drivers can then use in their tx
> ring cleanup (example implementation for mv643xx_eth included).

I like this changes a lot, so I've added them to net-next-2.6

If there are some problems found we can fix them up, and
also merging this now will better facilitate experimentation
with other drivers.

Thanks!
