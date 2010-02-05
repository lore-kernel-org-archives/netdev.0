From: Florian Westphal <fw@strlen.de>
Subject: Re: [RFC] xfrm: x86_64 CONFIG_COMPAT support
Date: Fri, 5 Feb 2010 22:13:28 +0100
Message-ID: <20100205211328.GC23792@Chamillionaire.breakpoint.cc>
References: <20100205014744.GD28659@Chamillionaire.breakpoint.cc>
 <20100204.202235.186522102.davem@davemloft.net>
 <20100205195409.GB23792@Chamillionaire.breakpoint.cc>
 <20100205.115913.103119415.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:58766 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751546Ab0BEVN3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2010 16:13:29 -0500
Content-Disposition: inline
In-Reply-To: <20100205.115913.103119415.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Fri, 5 Feb 2010 20:54:09 +0100
> 
> > However, I believe I can use is_compat_task() on
> > the userspace -> kernel side to figure out how to interpret
> > the incoming data.
> > 
> > Is that correct or did I misunderstand?
> 
> Again, you can't use is_compat_task().

Okay, understood. Thanks for clarifying.

> Just like netlink_recvmsg() you should use MSG_CMSG_COMPAT.
> 
> If it isn't be set correctly, you need to find out why.

Will do, thanks.
