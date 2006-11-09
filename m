From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCHSET] packet mark & fib rules work
Date: Thu, 9 Nov 2006 13:49:11 +0100
Message-ID: <20061109124911.GB8693@postel.suug.ch>
References: <20061109112735.577771022@lsx.localdomain> <20061109114604.GA32395@fogou.chygwyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:20945 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S965418AbWKIMsu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Nov 2006 07:48:50 -0500
To: Steven Whitehouse <steve@chygwyn.com>
Content-Disposition: inline
In-Reply-To: <20061109114604.GA32395@fogou.chygwyn.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Steven Whitehouse <steve@chygwyn.com> 2006-11-09 11:46
> On Thu, Nov 09, 2006 at 12:27:35PM +0100, Thomas Graf wrote:
> > Renames nfmark to mark and remove the dependency on netfilter
> > to ease usage by all subsystems. Also removes all the unneeded
> > config options to enable routing by fwmark, it can be safely
> > enabled by default.
> > 
> > Moves mark selector code from per protocol part into the generic
> > part and adds support for inverting selectors.
> > 
> 
> Acked-by: Steven Whitehouse <swhiteho@redhat.com>
> 
> so far as all the DECnet bits go. One question though... will you
> be adding later (as your slide #5 and #11 from your netconf presentation
> appear to imply) a way to set the mark from the routing table (presumably
> included in the nexthop info) ?

So far I haven't planned this, slide #11 describes that if I add an
address with a given mark the corresponding route will only apply
to packets with a matching mark. Slide #5 shows the idea of an ingress
classifier/action setting the mark field based on iif. I focus on
selecting routes based on marks, not the other way around but its
certainly a intersting idea if you can elaborate it further.
