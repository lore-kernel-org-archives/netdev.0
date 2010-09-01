From: David Miller <davem@davemloft.net>
Subject: Re: via-velocity dma-debug warnings again. (2.6.35.2)
Date: Wed, 01 Sep 2010 13:35:47 -0700 (PDT)
Message-ID: <20100901.133547.236248297.davem@davemloft.net>
References: <20100901.130333.148556201.davem@davemloft.net>
	<20100901200555.GA30689@redhat.com>
	<20100901.133414.24593005.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: simon.kagstrom@netinsight.net, netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45142
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752142Ab0IAUfa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 16:35:30 -0400
In-Reply-To: <20100901.133414.24593005.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 01 Sep 2010 13:34:14 -0700 (PDT)

> Ugh, while writing this I spotted another bug.  It can't do this
> ETH_ZLEN thing, it has to use skb_padto().  Otherwise it's just
> transmitting arbitrary kernel memory at the end of the SKB
> buffer onto the network which is a big no-no.  I'll fix that
> with another patch.

Actually, these ETH_ZLEN things in the length calculation can
just be deleted. It does in fact use skb_padto() properly earlier
in the xmit function.
