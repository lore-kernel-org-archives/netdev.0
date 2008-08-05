From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] bridge: fix compile warning in
 net/bridge/br_netfilter.c
Date: Tue, 05 Aug 2008 01:21:40 -0700 (PDT)
Message-ID: <20080805.012140.213243441.davem@davemloft.net>
References: <eb3ff54b0808042345j256d28aapbadc22a1ad994ca9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47009
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756260AbYHEIVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 04:21:39 -0400
In-Reply-To: <eb3ff54b0808042345j256d28aapbadc22a1ad994ca9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rami Rosen" <ramirose@gmail.com>
Date: Tue, 5 Aug 2008 09:45:00 +0300

> This patch fixes the following warning due to incompatible pointer assignment:
> 
> net/bridge/br_netfilter.c: In function 'br_netfilter_rtable_init':
> net/bridge/br_netfilter.c:116: warning: assignment from incompatible
> pointer type
> 
> This warning is due to commit 4adf0af6818f3ea52421dc0bae836cfaf20ef72a
> from  July 30
> (send correct MTU value in PMTU (revised)).
>
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied, thank you.
