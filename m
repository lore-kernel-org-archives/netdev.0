From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] net: add tracepoints to socket api
Date: Tue, 27 Jan 2009 15:42:07 -0500
Message-ID: <20090127204207.GA31299@hmsreliant.think-freely.org>
References: <20090127171857.GB14429@infradead.org> <20090127.092017.40699485.davem@davemloft.net> <20090127172323.GA7635@infradead.org> <20090127.102141.99756103.davem@davemloft.net> <20090127184704.GA26403@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57985 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751075AbZA0UmS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 15:42:18 -0500
Content-Disposition: inline
In-Reply-To: <20090127184704.GA26403@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 27, 2009 at 01:47:04PM -0500, Christoph Hellwig wrote:
> On Tue, Jan 27, 2009 at 10:21:41AM -0800, David Miller wrote:
> > The block layer already merged trace annotations.  I therefore see no
> > harm in merging the net bits.
> 
> The block layer also has a consumer for them (blktrace) and soon a
> second one (the ftrace plugin)
> 
> 

FWIW, ftrace is just as usefull for the network syscalls as any other set of
syscalls (hence my starting with the top layer of tracepoints).  I've also got
another use case thats been requested of me.  Specifically its been requested
that we have some unified method for tracking network drops in one place, so
that users don't have to use an amalgamation of tools to check statistics in
several places to find where their netowork packets are getting dropped.  I
thought defining a set of tracepoints to detect such drops might make the start
of a good solution.  Granted the existing tracepoints don't cover that use case
very well, but I like the idea of having the existing tracepoints in place
before I go adding new ones (to ensure that I don't duplicate effort).

Regards
Neil

