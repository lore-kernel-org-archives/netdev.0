From: Jens Rosenboom <jens@mcbone.net>
Subject: Re: [RFC] ipv6: Change %pI6 format to output compacted addresses?
Date: Thu, 13 Aug 2009 16:30:40 +0200
Message-ID: <1250173840.6641.81.camel@fnki-nb00130>
References: <1250091560.6641.48.camel@fnki-nb00130>
	 <20090813141840.GA25935@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Network Developers <netdev@vger.kernel.org>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from leia.mcbone.net ([194.97.104.42]:59098 "EHLO leia.mcbone.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751974AbZHMOaq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Aug 2009 10:30:46 -0400
In-Reply-To: <20090813141840.GA25935@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-08-13 at 10:18 -0400, Christoph Hellwig wrote:
> On Wed, Aug 12, 2009 at 05:39:20PM +0200, Jens Rosenboom wrote:
> > Currently the output looks like 2001:0db8:0000:0000:0000:0000:0000:0001
> > which might be compacted to 2001:db8::1. The code to do this could be
> > adapted from inet_ntop in glibc, which would add about 80 lines to
> > lib/vsprintf.c. How do you guys value the tradeoff between more readable
> > logging and increased kernel size?
> 
> A little note:  if you borrow code from glibc always make sure it's from
> an old enough version that is still GPLv2+ licensed.

The code for inet_ntop has as comment

 * author:
 *      Paul Vixie, 1996.

while the whole file is

Copyright (c) 1996-1999 by Internet Software Consortium.

so it should probably be old enough. But it also doesn't look too nice
to me, so I'll try to go without it for now.


