From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH RFC 0/9] socket filtering using nf_tables
Date: Fri, 4 Apr 2014 17:27:34 +0200
Message-ID: <20140404152734.GA3434@localhost>
References: <1394529560-3490-1-git-send-email-pablo@netfilter.org>
 <20140404.112432.523364323608428978.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35432 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753602AbaDDP1k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2014 11:27:40 -0400
Content-Disposition: inline
In-Reply-To: <20140404.112432.523364323608428978.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 04, 2014 at 11:24:32AM -0400, David Miller wrote:
> From: Pablo Neira Ayuso <pablo@netfilter.org>
> Date: Tue, 11 Mar 2014 10:19:11 +0100
> 
> > The following patchset provides a socket filtering alternative to BPF
> > which allows you to define your filter using the nf_tables expressions.
> 
> Generally I like this series, but of course you will need to respin
> it against the work that went into net-next recently.

Sure, no problem.

> I only wonder about the expression implementation module loading
> logic when we add an nft filter to a socket.

Yes, that needs to be revisited, some people already rised concerns on
that.

> It seems that if the module doesn't exist, we return -EAGAIN, drop the
> mutex, and retry.  I see nothing which breaks this loop, it seems like
> it can run forever if a module is simply not present.

Will recheck this as well. Thanks for the feedback.
