From: David Miller <davem@davemloft.net>
Subject: Re: [patch] netns: let net_generic take pointer-to-const args
Date: Sun, 21 Nov 2010 10:05:43 -0800 (PST)
Message-ID: <20101121.100543.39194352.davem@davemloft.net>
References: <alpine.LNX.2.01.1011210506110.9636@obet.zrqbmnf.qr>
	<1290328165.2756.102.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jengelh@medozas.de, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45205
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754645Ab0KUSFS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Nov 2010 13:05:18 -0500
In-Reply-To: <1290328165.2756.102.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 21 Nov 2010 09:29:25 +0100

> While you are at it you could also use
> 
> const struct net_generic *ng;
> 
> Just curious, if we could use __pure attribute as well.

Sounds like a good idea for a follow-on patch.
