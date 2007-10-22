From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] Use the skb_set_queue_mapping where appropriate
Date: Sun, 21 Oct 2007 17:01:03 -0700 (PDT)
Message-ID: <20071021.170103.85417880.davem@davemloft.net>
References: <471871E5.7060900@openvz.org>
	<47187244.1010603@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52727
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751235AbXJVAAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2007 20:00:49 -0400
In-Reply-To: <47187244.1010603@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 19 Oct 2007 13:00:52 +0400

> There's already such a helper to initialize this field.
> Use it.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.

>  			/* reset queue_mapping to zero */
> -			skb->queue_mapping = 0;
> +			skb_set_queue_mapping(skb, 0);

This right here is a great example why I add next to no comments to
the code I write.  They are %99.999 of the time stating the obvious,
and where a comment is needed it's the code's fault and the code in
such cases could be rewritten to make what's going on more clear thus
making any commentary, again, redundant and stating the obvious.

Here the case is the former, it's of the form:

	/* Add one to 'a'! */
	a += 1;

Gee thanks for letting me know!  How insightful! :-))

