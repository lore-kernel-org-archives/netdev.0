From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC] ipv6: Change %pI6 format to output compacted addresses?
Date: Thu, 13 Aug 2009 10:18:40 -0400
Message-ID: <20090813141840.GA25935@infradead.org>
References: <1250091560.6641.48.camel@fnki-nb00130>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Network Developers <netdev@vger.kernel.org>
To: Jens Rosenboom <jens@mcbone.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:48698 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103AbZHMOSj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 10:18:39 -0400
Content-Disposition: inline
In-Reply-To: <1250091560.6641.48.camel@fnki-nb00130>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 12, 2009 at 05:39:20PM +0200, Jens Rosenboom wrote:
> Currently the output looks like 2001:0db8:0000:0000:0000:0000:0000:0001
> which might be compacted to 2001:db8::1. The code to do this could be
> adapted from inet_ntop in glibc, which would add about 80 lines to
> lib/vsprintf.c. How do you guys value the tradeoff between more readable
> logging and increased kernel size?

A little note:  if you borrow code from glibc always make sure it's from
an old enough version that is still GPLv2+ licensed.

