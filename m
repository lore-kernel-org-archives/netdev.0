From: Simon Horman <horms@verge.net.au>
Subject: Re: nonlocal_bind & IPv6
Date: Wed, 30 Jun 2010 13:48:57 +0900
Message-ID: <20100630044854.GA16564@verge.net.au>
References: <201006252043.45581.michal.humpula@hudrydum.cz>
 <201006252110.08508.michal.humpula@hudrydum.cz>
 <20100626132540.GA30133@verge.net.au>
 <201006262242.16346.michal.humpula@hudrydum.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Michal Humpula <michal.humpula@hudrydum.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:41587 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751318Ab0F3Es6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jun 2010 00:48:58 -0400
Content-Disposition: inline
In-Reply-To: <201006262242.16346.michal.humpula@hudrydum.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 26, 2010 at 10:42:16PM +0200, Michal Humpula wrote:
> On Saturday 26 of June 2010 15:25:40 Simon Horman wrote:
> > On Fri, Jun 25, 2010 at 09:10:08PM +0200, Michal Humpula wrote:
> > > Ok, more detail example.
> > > 
> > > Let on each node be an apache (just for an example), and you configure
> > > VirtualHost for specific IP. So when node A fails, keepalived move IP to
> > > the node B and everything is still running. No need for restart of apache
> > > or anything else. There is a probably a better solution, but I can't find
> > > anything more simple than the posted patch:)
> > 
> > Not an answer to your original question, but that sounds like a problem
> > that can be resolved using IP_TRANSPARENT. Although I have only tested
> > that feature in conjunction with IPv4, it seems to support IPv6 too.
> > 
> > See Documentation/networking/tproxy.txt
> 
> Thanks for redirection. I don't think that IP_TRANSPARENT is suited well
> for my problem, but I did find the IP_FREEBIND in the process.
> Unfortunately it seems that both are enabled only for IPv4 and IPv6
> mapped addresses. 
> 
> So, is there any reason why IP_FREEBIND or nonlocal_bind sysctl is not in
> current IPv6 kernel implementation?

My suspicion is that its just an oversight.  A good way to either get it
fixed or have the idea buried would be to send some patches.

