From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: virt-manager broken by bind(0) in net-next.
Date: Sun, 1 Feb 2009 15:44:45 +0300
Message-ID: <20090201124445.GB2319@ioremap.net>
References: <20090130112125.GA9908@ioremap.net> <20090130125337.GA7155@gondor.apana.org.au> <20090130095737.103edbff@extreme> <498349F7.4050300@cosmosbay.com> <20090130215008.GB12210@ioremap.net> <20090131215850.3dfc29fb@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Herbert Xu <herbert@gondor.apana.org.au>, berrange@redhat.com,
	et-mgmt-tools@redhat.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cs-studio.ru ([195.178.208.66]:52743 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752358AbZBAMor (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Feb 2009 07:44:47 -0500
Content-Disposition: inline
In-Reply-To: <20090131215850.3dfc29fb@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 31, 2009 at 09:58:50PM -0800, Stephen Hemminger (shemminger@vyatta.com) wrote:
> > I think it should be smallest_size != -1, since we really want to goto
> > to the again label when hueristic is used, which in turn changes
> > smallest_size.
> 
> Yes, this fixes the problem, not sure who wants the honors for sending a signed off
> version.

Thanks for testing Stephen. David applied that version and cut the
Gordian knot :)

-- 
	Evgeniy Polyakov
