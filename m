From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add tracepoints to socket api
Date: Mon, 26 Jan 2009 21:57:03 -0800 (PST)
Message-ID: <20090126.215703.115893965.davem@davemloft.net>
References: <20090126195930.GA28208@hmsreliant.think-freely.org>
	<20090126.172253.25010769.davem@davemloft.net>
	<20090127013127.GB25660@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56445
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751688AbZA0F5F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 00:57:05 -0500
In-Reply-To: <20090127013127.GB25660@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Mon, 26 Jan 2009 23:31:27 -0200

> Em Mon, Jan 26, 2009 at 05:22:53PM -0800, David Miller escreveu:
> > From: Neil Horman <nhorman@tuxdriver.com>
> > Date: Mon, 26 Jan 2009 14:59:30 -0500
> > 
> > > @@ -95,6 +95,7 @@
> > >  
> > >  #include <net/sock.h>
> > >  #include <linux/netfilter.h>
> > > +#include <trace/socket.h>
> > 
> > Where is this mysterious include/trace/socket.h file?
> > I can't seem to find it :-)
> 
> Its something along the lines of include/trace/block.h, with the
> DECLARE_TRACE that match the DEFINE_TRACE entries he added, probably he
> forgot to git-add this new file :-)

I kind of figured as much, so now Neil just needs to respin his
patch with the relevant bits of that header file included.
