From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] net: sxgbe: fix error paths in sxgbe_platform_probe()
Date: Sun, 27 Mar 2016 10:22:54 +0200
Message-ID: <20160327082254.GA10620@electric-eye.fr.zoreil.com>
References: <877fgue1mx.fsf@rasmusvillemoes.dk>
 <1459027449-2667-1-git-send-email-linux@rasmusvillemoes.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51187 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754405AbcC0IXB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2016 04:23:01 -0400
Content-Disposition: inline
In-Reply-To: <1459027449-2667-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rasmus Villemoes <linux@rasmusvillemoes.dk> :
> We need to use post-decrement to ensure that irq_dispose_mapping is
> also called on priv->rxq[0]->irq_no; moreover, if one of the above for
> loops failed already at i==0 (so we reach one of these labels with
> that value of i), we'll enter an essentially infinite loop of
> out-of-bounds accesses.
> 
> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>

(ok, i is signed)

Reviewed-by: Francois Romieu <romieu@fr.zoreil.com>

Someone messed with my review on 2014/03/25 and got it wrong. :o/

Two years after the initial submission, there is zero change regarding use
of sxgbe_core_ops for extension or manageability. The extra indirection is
ripe for removal during next net-next.

-- 
Ueimor
