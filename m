From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] qlnic: dont set skb->truesize
Date: Mon, 20 Sep 2010 10:09:22 -0700 (PDT)
Message-ID: <20100920.100922.58424664.davem@davemloft.net>
References: <99737F4847ED0A48AECC9F4A1974A4B80F86F8018D@MNEXMB2.qlogic.org>
	<1284985118.3420.270.camel@edumazet-laptop>
	<1284985739.3420.284.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amit.salecha@qlogic.com, netdev@vger.kernel.org,
	ameen.rahman@qlogic.com, anirban.chakraborty@qlogic.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59962
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753637Ab0ITRJD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 13:09:03 -0400
In-Reply-To: <1284985739.3420.284.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 20 Sep 2010 14:28:59 +0200

> [PATCH net-next-2.6] qlnic: dont set skb->truesize
> 
> skb->truesize is set in core network.
> 
> Dont change it unless dealing with fragments.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Looks good to me too, applied thanks!
