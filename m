From: Jens Rosenboom <jens@mcbone.net>
Subject: Re: [RFC] ipv6: Change %pI6 format to output compacted addresses?
Date: Thu, 13 Aug 2009 15:52:23 +0200
Message-ID: <1250171543.6641.78.camel@fnki-nb00130>
References: <1250091560.6641.48.camel@fnki-nb00130>
	 <4A836D6D.1040400@hp.com>  <1250159961.28285.35.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Brian Haley <brian.haley@hp.com>,
	Linux Network Developers <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from leia.mcbone.net ([194.97.104.42]:57857 "EHLO leia.mcbone.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751974AbZHMNwd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Aug 2009 09:52:33 -0400
In-Reply-To: <1250159961.28285.35.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-08-13 at 03:39 -0700, Joe Perches wrote:
> On Wed, 2009-08-12 at 21:33 -0400, Brian Haley wrote:
> > Jens Rosenboom wrote:
> > > Currently the output looks like 2001:0db8:0000:0000:0000:0000:0000:0001
> > > which might be compacted to 2001:db8::1. The code to do this could be
> > > adapted from inet_ntop in glibc, which would add about 80 lines to
> > > lib/vsprintf.c. How do you guys value the tradeoff between more readable
> > > logging and increased kernel size?
> > > 
> > > This was already mentioned in
> > > http://kerneltrap.org/mailarchive/linux-netdev/2008/11/25/4231684 but
> > > noone seems to have taken up on it.
> > 
> > Anyways, can you try this patch, it's less than 40 new lines :)
> > It might be good enough, but could probably use some help.
> 
> You'll need to invent a new %p qualifier type to allow
> compressed representation.  Your patch will change current uses
> with seq_<foo> output in net, which could break userspace.

Would it be possible to transform this to using %pi6, as most of teh
seq_* stuff already does? It doesn't make sense to shorten the
un-colon-ed version anyway, I'll send an updated version of Brian's
patch soon.

