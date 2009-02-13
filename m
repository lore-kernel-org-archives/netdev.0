From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: Fix page seeking for skb_splice_bits().
Date: Thu, 12 Feb 2009 16:50:13 -0800 (PST)
Message-ID: <20090212.165013.41750032.davem@davemloft.net>
References: <20090211215806.GA2676@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48169
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750764AbZBMAuT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 19:50:19 -0500
In-Reply-To: <20090211215806.GA2676@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Wed, 11 Feb 2009 22:58:06 +0100

> So, you both were right there is something wrong with splice for
> multipage linear regions, at least theoretically. Since I don't know
> if this can really matter in practice (could NUMA slab allocate these
> pages from different tables?), I've done it against -net, but maybe
> -net-next is enough?

I'll add this to net-next-2.6 because I think it's theoretical at
best.  In fact I don't think we would get allocations across
NUMA nodes in this situation.

Thanks Jarek.
