From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [RFC PATCH V4 01/13] netback: page pool version 1
Date: Fri, 17 Feb 2012 14:19:02 -0500
Message-ID: <20120217191902.GD20584@phenom.dumpdata.com>
References: <1328201363-13915-1-git-send-email-wei.liu2@citrix.com>
 <1328201363-13915-2-git-send-email-wei.liu2@citrix.com>
 <1328203565.13262.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wei Liu <wei.liu2@citrix.com>, netdev@vger.kernel.org,
	xen-devel@lists.xensource.com, ian.campbell@citrix.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:35760 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752101Ab2BQTWQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2012 14:22:16 -0500
Content-Disposition: inline
In-Reply-To: <1328203565.13262.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> Hmm, this kind of stuff should be discussed on lkml.
> 
> I doubt we want yet another memory allocator, with a global lock
> (contended), and no NUMA properties.

That should be fixed. Are there any existing memory pools that could be used
instead? I (And I think everybody) is all for using the existing APIs if  they
can do the job. I was lookign a bit at the dmapool code, but that requires something
we don't have  - the 'struct device'. We could manufacture a fake one, but that just
stinks of hack.

It [pagepool] also should use the shrinker API I think.
