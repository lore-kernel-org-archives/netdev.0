From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] net: add tracepoints to socket api
Date: Wed, 28 Jan 2009 16:28:09 -0500
Message-ID: <20090128212809.GA19228@hmsreliant.think-freely.org>
References: <20090127171857.GB14429@infradead.org> <20090127.092017.40699485.davem@davemloft.net> <20090127172323.GA7635@infradead.org> <20090127.102141.99756103.davem@davemloft.net> <20090127184704.GA26403@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:56176 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751318AbZA1V2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 16:28:21 -0500
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

FWIW, ftrace will also work well on these syscalls (which I think is rather
usefull).  Another use case came across my path the other day too.  I've had
several requests from various people to find a way to provide unifying frame
drop indicators.  Basically people hate to have to dig through various stat
files and tools to look at all the places a frame can be dropped within our
network stack.  I think a nice solution to this problem might be some
tracepoints that people could use to gather comprehensive tx/rx frame drop
information using one tool.  Of course, these provided tracepoints don't do
that, but I think it would be good to get the existing tracepoint set in before
I go poking at an implementation of that, just to ensure I avoid duplicate work

Neil


