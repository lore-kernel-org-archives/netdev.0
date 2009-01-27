From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH] net: add tracepoints to socket api
Date: Mon, 26 Jan 2009 23:31:27 -0200
Message-ID: <20090127013127.GB25660@ghostprotocols.net>
References: <20090126195930.GA28208@hmsreliant.think-freely.org> <20090126.172253.25010769.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:49612 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750989AbZA0Bbi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jan 2009 20:31:38 -0500
Content-Disposition: inline
In-Reply-To: <20090126.172253.25010769.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Mon, Jan 26, 2009 at 05:22:53PM -0800, David Miller escreveu:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Mon, 26 Jan 2009 14:59:30 -0500
> 
> > @@ -95,6 +95,7 @@
> >  
> >  #include <net/sock.h>
> >  #include <linux/netfilter.h>
> > +#include <trace/socket.h>
> 
> Where is this mysterious include/trace/socket.h file?
> I can't seem to find it :-)

Its something along the lines of include/trace/block.h, with the
DECLARE_TRACE that match the DEFINE_TRACE entries he added, probably he
forgot to git-add this new file :-)

- Arnaldo
