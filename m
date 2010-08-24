From: David Miller <davem@davemloft.net>
Subject: Re: [Bridge] [PATCH v2] bridge: netfilter: fix a memory leak
Date: Mon, 23 Aug 2010 20:15:20 -0700 (PDT)
Message-ID: <20100823.201520.90820084.davem@davemloft.net>
References: <1282539806-25496-1-git-send-email-xiaosuo@gmail.com>
	<4C72CD1C.7020901@pandora.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: bdschuym@pandora.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45849
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751756Ab0HXDPD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 23:15:03 -0400
In-Reply-To: <4C72CD1C.7020901@pandora.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bart De Schuymer <bdschuym@pandora.be>
Date: Mon, 23 Aug 2010 21:33:48 +0200

> Looks correct to me.
> 
> Signed-off-by: Bart De Schuymer <bdschuym@pandora.be>

Bart, please do not top post.

> Changli Gao schreef:
>> nf_bridge_alloc() always reset the skb->nf_bridge, so we should always
>> put the old one.
>>
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Applied, thanks everyone.
