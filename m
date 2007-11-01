From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/8] Make the sk_clone() lighter
Date: Thu, 01 Nov 2007 00:38:15 -0700 (PDT)
Message-ID: <20071101.003815.65813128.davem@davemloft.net>
References: <472885B1.7090103@openvz.org>
	<4728891A.30305@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35391
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754174AbXKAHiP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 03:38:15 -0400
In-Reply-To: <4728891A.30305@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Wed, 31 Oct 2007 16:54:34 +0300

> The sk_prot_alloc() already performs all the stuff needed by the
> sk_clone(). Besides, the sk_prot_alloc() requires almost twice
> less arguments than the sk_alloc() does, so call the sk_prot_alloc()
> saving the stack a bit.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

I reread this patch and now I understand why it's correct.

When zero_it argument is zero, as was the case here, all of
the sk->sk_net processing is not done.

Applied, thanks.
