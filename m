From: David Miller <davem@davemloft.net>
Subject: Re: [XFRM]: beet: fix worst case header_len calculation
Date: Mon, 09 Apr 2007 11:48:40 -0700 (PDT)
Message-ID: <20070409.114840.18284797.davem@davemloft.net>
References: <461859F3.50303@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51391
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753401AbXDISsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2007 14:48:41 -0400
In-Reply-To: <461859F3.50303@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Sun, 08 Apr 2007 04:56:51 +0200

> The pskb_copy_expand crash I was seeing was triggered by BEET
> mode not calculating the SA's header_len value for the worst
> case, causing skb headroom expansions. This patch uses the
> worst case value by including the maximum length of the pseudo
> header.
> 
> The patch applies on top of the MTU optimization patch.

Applied, thanks Patrick.

Can you backport this to 2.6.21 for me, if you think we should
bother?  Thanks.

