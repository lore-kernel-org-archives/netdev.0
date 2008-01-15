From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] skb_partial_csum_set
Date: Tue, 15 Jan 2008 03:14:22 -0800 (PST)
Message-ID: <20080115.031422.06112893.davem@davemloft.net>
References: <200801152141.56172.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45367
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750981AbYAOLOW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 06:14:22 -0500
In-Reply-To: <200801152141.56172.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Tue, 15 Jan 2008 21:41:55 +1100

> Implement skb_partial_csum_set, for setting partial csums on untrusted packets.
> 
> Use it in virtio_net (replacing buggy version there), it's also going
> to be used by TAP for partial csum support.
> 
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

Looks fine to me.

Acked-by: David S. Miller <davem@davemloft.net>

If you like I can merge this into my net-2.6.25 tree, or alternatively
if it makes your life easier you then you can handle it yourself.
