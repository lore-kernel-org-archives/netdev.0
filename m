From: Patrick McHardy <kaber@trash.net>
Subject: Re: [XFRM]: beet: fix worst case header_len calculation
Date: Mon, 09 Apr 2007 20:49:59 +0200
Message-ID: <461A8AD7.90607@trash.net>
References: <461859F3.50303@trash.net> <20070409.114840.18284797.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42218 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932183AbXDISuQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2007 14:50:16 -0400
In-Reply-To: <20070409.114840.18284797.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Sun, 08 Apr 2007 04:56:51 +0200
> 
> 
>>The pskb_copy_expand crash I was seeing was triggered by BEET
>>mode not calculating the SA's header_len value for the worst
>>case, causing skb headroom expansions. This patch uses the
>>worst case value by including the maximum length of the pseudo
>>header.
>>
>>The patch applies on top of the MTU optimization patch.
> 
> 
> Applied, thanks Patrick.
> 
> Can you backport this to 2.6.21 for me, if you think we should
> bother?  Thanks.


Its merely an optimization, so I don't think we should put it in 2.6.21
at this point in the release cycle.
