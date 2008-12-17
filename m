From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2.6.29 v2 1/5] gianfar: Fix skb allocation error
Date: Wed, 17 Dec 2008 12:22:52 -0800 (PST)
Message-ID: <20081217.122252.267759802.davem@davemloft.net>
References: <1229539981-14041-1-git-send-email-afleming@freescale.com>
	<1229539981-14041-2-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38127
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751240AbYLQUW4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 15:22:56 -0500
In-Reply-To: <1229539981-14041-2-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Fleming <afleming@freescale.com>
Date: Wed, 17 Dec 2008 12:52:57 -0600

> We don't want to unmap the skb if we've decided to use the old one, so we only
> unmap it if we're *not* using the old one.
> 
> Signed-off-by: Andy Fleming <afleming@freescale.com>

Andy.... look at what you're doing here.  Your patch talks about DMA
mapping, yet the patch deals with protecting an SKB free call.

Your commit message matches the original patch but not this one.

In fact I fear that, in fact, there was a bug being fixed originally,
and in fact you do need to modify where the DMA unmap occurs in this
function, but in fixing up the patch to apply you've not gotten that
part straight.

I'm tossing these patches again.  If the commit message can't even
match what the patch is doing, you need to take a good long look at
these changes and then resubmit them with accurate commit messages.

Thanks.
