From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 2/2] [RFC] netlink: fix possible spoofing from non-root
 processes
Date: Mon, 20 Aug 2012 21:09:15 +0200
Message-ID: <20120820190915.GA3727@1984>
References: <1345224149-5946-1-git-send-email-pablo@netfilter.org>
 <1345224149-5946-3-git-send-email-pablo@netfilter.org>
 <20120819212327.GA14853@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43364 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752034Ab2HTTJS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Aug 2012 15:09:18 -0400
Content-Disposition: inline
In-Reply-To: <20120819212327.GA14853@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 19, 2012 at 11:23:27PM +0200, Pablo Neira Ayuso wrote:
> On Fri, Aug 17, 2012 at 07:22:29PM +0200, pablo@netfilter.org wrote:
> [...]
> > [ I don't know any FOSS program making use of Netlink to communicate
> >   to processes, please, let me know if I'm missing anyone important ]
> 
> Patrick pinged me for little reminder on NETLINK_USERSOCK. We still
> have to allow netlink-to-netlink userspace communication for it.
> 
> So, please find a new version of this patch that allows non-root
> processes for that Netlink bus. For others, my patch restricts to root
> processes the ability of sending messages with dst_pid != 0.

Sorry, I just noticed that you cannot apply this to your net tree
since it depends on patch 1/2 which is not a fix.

I'll get back to you with one path that you can apply to your net
tree.

I'll resend 1/2 later to net-next once this has been sorted out.
