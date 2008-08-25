From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix tcp header size miscalculation when window
 scale is unused
Date: Sun, 24 Aug 2008 17:45:44 -0700 (PDT)
Message-ID: <20080824.174544.244704849.davem@davemloft.net>
References: <20080823.214013.29359753.davem@davemloft.net>
	<396556a20805301217k293e5718h6bbf02bfe069081@europa>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, love_phil@emc.com
To: agl@imperialviolet.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56626
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752368AbYHYAps (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Aug 2008 20:45:48 -0400
In-Reply-To: <396556a20805301217k293e5718h6bbf02bfe069081@europa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Adam Langley" <agl@imperialviolet.org>
Date: Sun, 24 Aug 2008 10:40:23 -0700

> From: Philip Love <love_phil@emc.com>
> 
> tcp: fix tcp header size miscalculation when window scale is unused
> 
> The size of the TCP header is miscalculated when the window scale ends up being
> 0. Additionally, this can be induced by sending a SYN to a passive open port
> with a window scale option with value 0.
> 
> Signed-off-by: Philip Love <love_phil@emc.com>
> Signed-off-by: Adam Langley <agl@imperialviolet.org>

Adam I really appreciate you're fixing up the patch for Philip, but
how in the world is he ever going to learn how to submit a patch
properly if you just do it for him?

I could have fixed it up too, but I pushed it back so that he learns
how to submit a patch correctly, and this will help him and the rest
of us in the future when he wants to submit other patches.
