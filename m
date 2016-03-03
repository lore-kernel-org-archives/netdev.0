From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH v2 06/20] iproute: TYPE keyword is not optional,
 fix help text accordingly
Date: Thu, 3 Mar 2016 16:05:57 +0100
Message-ID: <20160303150557.GE18624@orbyte.nwl.cc>
References: <20160302093800.7e7dbe71@xeon-e3>
 <1456942808-15946-1-git-send-email-phil@nwl.cc>
 <1456942808-15946-7-git-send-email-phil@nwl.cc>
 <56D84883.3080902@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemming@brocade.com>, netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:38418 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751247AbcCCPF7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2016 10:05:59 -0500
Content-Disposition: inline
In-Reply-To: <56D84883.3080902@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 03, 2016 at 09:21:55AM -0500, Jamal Hadi Salim wrote:
> On 16-03-02 01:19 PM, Phil Sutter wrote:
> > +	fprintf(stderr, "          unreachable | prohibit | blackhole | nat }\n");
> 
> Dont think nat exists anymore...

But iproute2 seems to still support it? At least it's listed in
rtnl_rtntype_a2n().

The entry for RTN_NAT in net/ipv4/fib_semantics.c though looks like just
a stub. But at least it hasn't changed since the beginning of Git.
According to ip-route.8 it's indeed non-functional.

I only concerned help text and man page consistency, and since the man
page lists it (with a useful hint about it's state), the help text
should contain it either. Or do you think that's misleading?

Thanks, Phil
