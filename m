From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] xfrm: x86_64 CONFIG_COMPAT support
Date: Fri, 05 Feb 2010 11:59:13 -0800 (PST)
Message-ID: <20100205.115913.103119415.davem@davemloft.net>
References: <20100205014744.GD28659@Chamillionaire.breakpoint.cc>
	<20100204.202235.186522102.davem@davemloft.net>
	<20100205195409.GB23792@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42415
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933841Ab0BET67 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2010 14:58:59 -0500
In-Reply-To: <20100205195409.GB23792@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Fri, 5 Feb 2010 20:54:09 +0100

> I had a look at the wireless compat layer you mentioned;
> when sending data to userspace one just prepares two
> skbs (one native, one compat); netlink_recvmsg() then decides
> which one to use for a particular receiver.
> 
> However, I believe I can use is_compat_task() on
> the userspace -> kernel side to figure out how to interpret
> the incoming data.
> 
> Is that correct or did I misunderstand?

Again, you can't use is_compat_task().

Just like netlink_recvmsg() you should use MSG_CMSG_COMPAT.

If it isn't be set correctly, you need to find out why.
