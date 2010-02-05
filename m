From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] xfrm: x86_64 CONFIG_COMPAT support
Date: Thu, 04 Feb 2010 20:22:35 -0800 (PST)
Message-ID: <20100204.202235.186522102.davem@davemloft.net>
References: <20100205014744.GD28659@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45253
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751477Ab0BEEWW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2010 23:22:22 -0500
In-Reply-To: <20100205014744.GD28659@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Fri, 5 Feb 2010 02:47:44 +0100

> Unfortunately, the MSG_COMPAT flag seems to get lost along
> the way, so this uses x86_64 is_compat_task() for now.

You can't use is_compat_task() for this.  The current
execution context is not always the same as who is
going to get the message.

This is particularly the case for broadcast events, and
key manager event sending.

The wireless folks have their netlink bits working with
compat programs, you should go see how it works there.
