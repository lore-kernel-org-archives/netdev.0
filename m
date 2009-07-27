From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: shrink net_device by #ifdef-ing protocol-specific
 members
Date: Mon, 27 Jul 2009 08:26:44 -0700 (PDT)
Message-ID: <20090727.082644.265102452.davem@davemloft.net>
References: <4A6DC314.2010303@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: lgrijincu@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40536
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752127AbZG0P0h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 11:26:37 -0400
In-Reply-To: <4A6DC314.2010303@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>
Date: Mon, 27 Jul 2009 18:09:08 +0300

> Some members of net_device are used only by some protocols.
> 
> If those protocols are not compiled (as modules or linked in) they
> should not take up space in the structure.

This benefits, at best, %0.000000001 of users of the Linux kernel,
because every distribution is going to turn on every single option.

If you want to shrink structures, find ways to eliminate or
shrink structure members in all cases.

I'm not applying this.
