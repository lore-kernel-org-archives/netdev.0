From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [RFC v2] net: Introduce recvmmsg socket syscall
Date: Thu, 11 Jun 2009 12:34:46 -0300
Message-ID: <20090611153444.GE22424@ghostprotocols.net>
References: <20090611034022.GC22424@ghostprotocols.net> <20090611.024100.233245804.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, vanhoof@redhat.com, williams@redhat.com,
	caitlin.bestler@gmail.com, paul.moore@hp.com, steve@chygwyn.com,
	remi.denis-courmont@nokia.com, nhorman@tuxdriver.com,
	niv@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:38204 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751972AbZFKPfR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2009 11:35:17 -0400
Content-Disposition: inline
In-Reply-To: <20090611.024100.233245804.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Thu, Jun 11, 2009 at 02:41:00AM -0700, David Miller escreveu:
> From: Arnaldo Carvalho de Melo <acme@redhat.com>
> Date: Thu, 11 Jun 2009 00:40:22 -0300
> 
> > +	struct compat_timespec *timeout_compat =
> > +		(struct compat_timespec *)timeout;
> 
> In order for this to build on non-compat platforms, or when
> CONFIG_COMPAT is disabled, you'll need to avoid trying to
> reference compat_timespec.
> 
> We get away with compat_msghdr because we define it as a NOP
> in net/compat.h when necessary.
> 
> Doing the same, and cleanly, with this non-networking compat knob is
> unlikely to be straightforward.

Done, not like msghdr, but should work, testing now.

Thanks for quickly pointing out this brainfart!

- Arnaldo
