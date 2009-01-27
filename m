From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] net: add tracepoints to socket api
Date: Tue, 27 Jan 2009 07:09:51 -0500
Message-ID: <20090127120951.GB3898@hmsreliant.think-freely.org>
References: <20090126195930.GA28208@hmsreliant.think-freely.org> <20090126.172253.25010769.davem@davemloft.net> <20090127013127.GB25660@ghostprotocols.net> <20090126.215703.115893965.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: acme@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:34009 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752874AbZA0MKC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 07:10:02 -0500
Content-Disposition: inline
In-Reply-To: <20090126.215703.115893965.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 26, 2009 at 09:57:03PM -0800, David Miller wrote:
> From: Arnaldo Carvalho de Melo <acme@redhat.com>
> Date: Mon, 26 Jan 2009 23:31:27 -0200
> 
> > Em Mon, Jan 26, 2009 at 05:22:53PM -0800, David Miller escreveu:
> > > From: Neil Horman <nhorman@tuxdriver.com>
> > > Date: Mon, 26 Jan 2009 14:59:30 -0500
> > > 
> > > > @@ -95,6 +95,7 @@
> > > >  
> > > >  #include <net/sock.h>
> > > >  #include <linux/netfilter.h>
> > > > +#include <trace/socket.h>
> > > 
> > > Where is this mysterious include/trace/socket.h file?
> > > I can't seem to find it :-)
> > 
> > Its something along the lines of include/trace/block.h, with the
> > DECLARE_TRACE that match the DEFINE_TRACE entries he added, probably he
> > forgot to git-add this new file :-)
> 
> I kind of figured as much, so now Neil just needs to respin his
> patch with the relevant bits of that header file included.
> 

Grr, knew something like this would happen.  Its apparently impossible for me to
send something up without missing something obvious :).  My bad.  I'll
respin/repost in just a bit
Neil

